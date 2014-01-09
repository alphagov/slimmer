module Slimmer
  class Skin
    attr_accessor :use_cache, :template_cache, :asset_host, :logger, :strict, :options

    # TODO: Extract the cache to something we can pass in instead of using
    # true/false and an in-memory cache.
    def initialize options = {}
      @options = options
      @asset_host = options[:asset_host]

      @use_cache = options[:use_cache] || false
      @cache_ttl = options[:cache_ttl] || (15 * 60) # 15 mins
      @template_cache = LRUCache.new(:ttl => @cache_ttl) if @use_cache

      @logger = options[:logger] || NullLogger.instance
      @strict = options[:strict] || (%w{development test}.include?(ENV['RACK_ENV']))
    end

    def template(template_name)
      if use_cache
        template_cache.fetch(template_name) do
          load_template(template_name)
        end
      else
        load_template(template_name)
      end
    end

    def load_template(template_name)
      url = template_url(template_name)
      source = open(url, "r:UTF-8", :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE).read
      if template_name =~ /\.raw/
        template = source
      else
        template = ERB.new(source).result binding
      end
      template
    rescue OpenURI::HTTPError => e
      raise TemplateNotFoundException, "Unable to fetch: '#{template_name}' from '#{url}' because #{e}", caller
    rescue Errno::ECONNREFUSED => e
      raise CouldNotRetrieveTemplate, "Unable to fetch: '#{template_name}' from '#{url}' because #{e}", caller
    rescue SocketError => e
      raise CouldNotRetrieveTemplate, "Unable to fetch: '#{template_name}' from '#{url}' because #{e}", caller
    end

    def template_url(template_name)
      host = asset_host.dup
      host += '/' unless host =~ /\/$/
      "#{host}templates/#{template_name}.html.erb"
    end

    def report_parse_errors_if_strict!(nokogiri_doc, description_for_error_message)
      nokogiri_doc
    end

    def parse_html(html, description_for_error_message)
      doc = Nokogiri::HTML.parse(html)
      if strict
        errors = doc.errors.select {|e| e.error?}.reject {|e| ignorable?(e)}
        if errors.size > 0
          error = errors.first
          message = "In #{description_for_error_message}: '#{error.message}' at line #{error.line} col #{error.column} (code #{error.code}).\n"
          message << "Add ?skip_slimmer=1 to the url to show the raw backend request.\n\n"
          message << context(html, error)
          raise message
        end
      end

      doc
    end

    def context(html, error)
      context_size = 5
      lines = [""] + html.split("\n")
      from = [1, error.line - context_size].max
      to = [lines.size - 1, error.line + context_size].min
      context = (from..to).zip(lines[from..to]).map {|lineno, line| "%4d: %s" % [lineno, line] }
      marker = " " * (error.column - 1) + "-----v"
      context.insert(context_size, marker)
      context.join("\n")
    end

    def ignorable?(error)
      ignorable_codes = [801]
      ignorable_codes.include?(error.code) || error.message.match(/Element script embeds close tag/) || error.message.match(/Unexpected end tag : noscript/)
    end

    def process(processors,body,template)
      logger.debug "Slimmer: starting skinning process"
      src = parse_html(body.to_s, "backend response")
      dest = parse_html(template, "template")

      start_time = Time.now
      logger.debug "Slimmer: Start time = #{start_time}"
      processors.each do |p|
        processor_start_time = Time.now
        logger.debug "Slimmer: Processor #{p} started at #{processor_start_time}"
        begin
          p.filter(src,dest)
        rescue => e
          logger.error "Slimmer: Failed while processing #{p}: #{[ e.message, e.backtrace ].flatten.join("\n")}"
        end
        processor_end_time = Time.now
        process_time = processor_end_time - processor_start_time
        logger.debug "Slimmer: Processor #{p} ended at #{processor_end_time} (#{process_time}s)"
      end
      end_time = Time.now
      logger.debug "Slimmer: Skinning process completed at #{end_time} (#{end_time - start_time}s)"

      dest.to_html
    end

    def success(source_request, response, body)
      artefact = artefact_from_header(response)
      processors = [
        Processors::TitleInserter.new(),
        Processors::TagMover.new(),
        Processors::NavigationMover.new(self),
        Processors::ConditionalCommentMover.new(),
        Processors::BodyInserter.new(options[:wrapper_id] || 'wrapper'),
        Processors::BodyClassCopier.new,
        Processors::HeaderContextInserter.new(),
        Processors::SectionInserter.new(artefact),
        Processors::GoogleAnalyticsConfigurator.new(response, artefact),
        Processors::SearchPathSetter.new(response),
        Processors::RelatedItemsInserter.new(self, artefact),
        Processors::LogoClassInserter.new(artefact),
        Processors::ReportAProblemInserter.new(self, source_request.url, response.headers),
        Processors::SearchIndexSetter.new(response),
        Processors::MetaViewportRemover.new(response),
        Processors::BetaNoticeInserter.new(self, response.headers),
      ]

      template_name = response.headers[Headers::TEMPLATE_HEADER] || 'wrapper'
      process(processors, body, template(template_name))
    end

    def error(template_name, body)
      processors = [
        Processors::TitleInserter.new()
      ]
      process(processors, body, template(template_name))
    end

    def artefact_from_header(response)
      if response.headers.include?(Headers::ARTEFACT_HEADER)
        Artefact.new JSON.parse(response.headers[Headers::ARTEFACT_HEADER])
      else
        nil
      end
    rescue JSON::ParserError => e
      logger.error "Slimmer: Failed while parsing artefact header: #{[ e.message, e.backtrace ].flatten.join("\n")}"
      nil
    end
  end
end
