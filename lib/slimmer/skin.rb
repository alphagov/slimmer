module Slimmer
  class Skin
    attr_accessor :use_cache
    private :use_cache=, :use_cache

    attr_accessor :templated_cache
    private :templated_cache=, :templated_cache

    attr_accessor :asset_host
    private :asset_host=, :asset_host

    attr_accessor :prefix
    private :prefix=, :prefix

    attr_accessor :logger
    private :logger=, :logger

    attr_accessor :strict
    private :strict=, :strict

    attr_accessor :options
    private :options=, :options

    # TODO: Extract the cache to something we can pass in instead of using
    # true/false and an in-memory cache.
    def initialize options = {}
      self.options = options
      self.asset_host = options[:asset_host]
      self.templated_cache = {}
      self.prefix = options[:prefix]
      self.use_cache = options[:use_cache] || false
      self.logger = options[:logger] || NullLogger.instance
      self.strict = options[:strict] || (%w{development test}.include?(ENV['RACK_ENV']))
    end

    def template(template_name)
      logger.debug "Slimmer: Looking for template '#{template_name}'"
      return cached_template(template_name) if template_cached? template_name
      logger.debug "Slimmer: Asking for the template to be loaded"
      load_template template_name
    end

    def template_cached? name
      logger.debug "Slimmer: Checking cache for template '#{name}'"
      cached = !cached_template(name).nil?
      logger.debug "Slimmer: Cache hit = #{cached}"
      cached
    end

    def cached_template name
      logger.debug "Slimmer: Trying to load cached template '#{name}'"
      templated_cache[name]
    end

    def cache name, template
      logger.debug "Slimmer: Asked to cache '#{name}'. use_cache = #{use_cache}"
      return unless use_cache
      logger.debug "Slimmer: performing caching"
      templated_cache[name] = template
    end

    def load_template template_name
      logger.debug "Slimmer: Loading template '#{template_name}'"
      url = template_url template_name
      logger.debug "Slimmer: template lives at '#{url}'"
      source = open(url, "r:UTF-8", :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE).read
      if template_name =~ /\.raw/
        logger.debug "Slimmer: reading the raw template"
        template = source
      else
        logger.debug "Slimmer: Evaluating the template as ERB"
        template = ERB.new(source).result binding
      end
      cache template_name, template
      logger.debug "Slimmer: Returning evaluated template"
      template
    rescue OpenURI::HTTPError => e
      raise TemplateNotFoundException, "Unable to fetch: '#{template_name}' from '#{url}' because #{e}", caller
    rescue Errno::ECONNREFUSED => e
      raise CouldNotRetrieveTemplate, "Unable to fetch: '#{template_name}' from '#{url}' because #{e}", caller
    end

    def template_url template_name
      host = asset_host.dup
      host += '/' unless host =~ /\/$/
      "#{host}templates/#{template_name}.html.erb"
    end

    def error(request, template_name, body)
      processors = [
        TitleInserter.new()
      ]
      process(processors, body, template(template_name))
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

      # this is a horrible fix to Nokogiri removing the closing </noscript> tag required by Google Website Optimizer. 
      # http://www.google.com/support/websiteoptimizer/bin/answer.py?hl=en_us&answer=64418
      dest.to_html.sub(/<noscript rel=("|')placeholder("|')>/, "")
    end

    def admin(request,body)
      processors = [
        TitleInserter.new(),
        TagMover.new(),
        AdminTitleInserter.new,
        FooterRemover.new,
        BodyInserter.new(),
        BodyClassCopier.new,
      ]
      process(processors,body,template('admin'))
    end

    def success(source_request, request, body)
      processors = [
        TitleInserter.new(),
        TagMover.new(),
        BodyInserter.new(options[:wrapper_id] || 'wrapper'),
        BodyClassCopier.new,
        HeaderContextInserter.new(),
        SectionInserter.new(),
        GoogleAnalyticsConfigurator.new(request.env),
        RelatedItemsInserter.new(template('related.raw'), source_request),
      ]
      
      template_name = request.env.has_key?(TEMPLATE_HEADER) ? request.env[TEMPLATE_HEADER] : 'wrapper'
      process(processors,body,template(template_name))
    end
  end
end
