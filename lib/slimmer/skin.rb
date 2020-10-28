require "rest_client"
require "slimmer/govuk_request_id"

module Slimmer
  class Skin
    attr_accessor :asset_host, :logger, :strict, :options

    def initialize(options = {})
      @options = options
      @asset_host = options[:asset_host]

      @logger = options[:logger] || NullLogger.instance
      @strict = options[:strict] || %w[development test].include?(ENV["RACK_ENV"])
    end

    def template(template_name)
      Slimmer.cache.fetch(template_name, expires_in: Slimmer::CACHE_TTL) do
        load_template(template_name)
      end
    end

    def load_template(template_name)
      url = template_url(template_name)
      HTTPClient.get(url)
    rescue RestClient::Exception => e
      raise TemplateNotFoundException, "Unable to fetch: '#{template_name}' from '#{url}' because #{e}", caller
    rescue Errno::ECONNREFUSED, SocketError, OpenSSL::SSL::SSLError => e
      raise CouldNotRetrieveTemplate, "Unable to fetch: '#{template_name}' from '#{url}' because #{e}", caller
    end

    def template_url(template_name)
      host = asset_host.dup
      host += "/" unless host =~ /\/$/
      "#{host}templates/#{template_name}.html.erb"
    end

    def report_parse_errors_if_strict!(nokogiri_doc, _description_for_error_message)
      nokogiri_doc
    end

    def parse_html(html, description_for_error_message)
      doc = Nokogiri::HTML.parse(html)
      if strict
        errors = doc.errors.select(&:error?).reject { |e| ignorable?(e) }
        unless errors.empty?
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
      context = (from..to).zip(lines[from..to]).map { |lineno, line| sprintf("%4d: %s", lineno, line) }
      marker = " " * (error.column - 1) + "-----v"
      context.insert(context_size, marker)
      context.join("\n")
    end

    def ignorable?(error)
      ignorable_codes = [801]
      ignorable_codes.include?(error.code) || error.message.match(/Element script embeds close tag/) || error.message.match(/Unexpected end tag : noscript/)
    end

    def process(processors, body, template, _rack_env)
      logger.debug "Slimmer: starting skinning process"
      src = parse_html(body.to_s, "backend response")
      dest = parse_html(template, "template")

      start_time = Time.now
      logger.debug "Slimmer: Start time = #{start_time}"
      processors.each do |p|
        processor_start_time = Time.now
        logger.debug "Slimmer: Processor #{p} started at #{processor_start_time}"
        p.filter(src, dest)
        processor_end_time = Time.now
        process_time = processor_end_time - processor_start_time
        logger.debug "Slimmer: Processor #{p} ended at #{processor_end_time} (#{process_time}s)"
      end
      end_time = Time.now
      logger.debug "Slimmer: Skinning process completed at #{end_time} (#{end_time - start_time}s)"

      dest.to_html
    end

    def success(source_request, response, body)
      wrapper_id = options[:wrapper_id] || "wrapper"

      processors = [
        Processors::TitleInserter.new,
        Processors::TagMover.new,
        Processors::NavigationMover.new(self),
        Processors::ConditionalCommentMover.new,
        Processors::BodyInserter.new(wrapper_id),
        Processors::BodyClassCopier.new,
        Processors::InsideHeaderInserter.new,
        Processors::HeaderContextInserter.new,
        Processors::MetadataInserter.new(response, options[:app_name]),
        Processors::SearchParameterInserter.new(response),
        Processors::SearchPathSetter.new(response),
        Processors::SearchRemover.new(response.headers),
        Processors::AccountsShower.new(response.headers),
      ]

      template_name = response.headers[Headers::TEMPLATE_HEADER] || "core_layout"
      process(processors, body, template(template_name), source_request.env)
    end
  end
end
