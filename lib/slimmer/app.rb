require "slimmer/govuk_request_id"

module Slimmer
  class App
    attr_accessor :logger

    def initialize(app, *args)
      options = args.first || {}
      @app = app

      logger = options[:logger] || NullLogger.instance
      self.logger = logger
      if logger&.level&.zero? # Log set to debug level
        unless options[:enable_debugging]
          self.logger = logger.dup
          self.logger.level = 1 # info
        end
      end

      if options.key? :template_path
        raise "Template path should not be used. Use asset_host instead."
      end

      unless options[:asset_host]
        options[:asset_host] = Plek.current.find("static")
      end

      @skin = Skin.new options.merge(logger: self.logger)
    end

    def call(env)
      logger.debug "Slimmer: capturing response"
      status, headers, body = @app.call(env)

      if response_can_be_rewritten?(status, headers)
        response = Rack::Response.new(body, status, headers)

        if !skip_slimmer?(env, response)
          status, headers, body = rewrite_response(env, response)
        end
      end

      [status, strip_slimmer_headers(headers), body]
    end

    def response_can_be_rewritten?(status, headers)
      Rack::Utils::HeaderHash.new(headers)["Content-Type"] =~ /text\/html/ && ![301, 302, 304].include?(status)
    end

    def skip_slimmer?(env, response)
      (in_development? && skip_slimmer_param?(env)) || skip_slimmer_header?(response)
    end

    def in_development?
      ENV["RAILS_ENV"] == "development"
    end

    def skip_slimmer_param?(env)
      skip = Rack::Request.new(env).params["skip_slimmer"]
      skip && skip.to_i.positive?
    end

    def skip_slimmer_header?(response)
      !!response.headers[Headers::SKIP_HEADER]
    end

    def s(body)
      return body.to_s unless body.respond_to?(:each)

      b = ""
      body.each { |a| b << a }
      b
    end

    def content_length(rewritten_body)
      size = 0
      rewritten_body.each { |part| size += part.bytesize }
      size.to_s
    end

    def rewrite_response(env, response)
      request = Rack::Request.new(env)

      # Store the request id so it can be passed on with any template requests
      GovukRequestId.value = env["HTTP_GOVUK_REQUEST_ID"]

      rewritten_body = case response.status
                       when 200
                         @skin.success request, response, s(response.body)
                       when 403
                         @skin.error "403", s(response.body), request.env
                       when 404
                         @skin.error "404", s(response.body), request.env
                       when 410
                         @skin.error "410", s(response.body), request.env
                       else
                         @skin.error "500", s(response.body), request.env
                       end

      rewritten_body = [rewritten_body] unless rewritten_body.respond_to?(:each)
      response.body = rewritten_body
      response.headers["Content-Length"] = content_length(response.body)

      response.finish
    end

    def strip_slimmer_headers(headers)
      headers.reject { |k, _v| k =~ /\A#{Headers::HEADER_PREFIX}/ }
    end
  end
end
