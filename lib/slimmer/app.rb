module Slimmer
  class App
    attr_accessor :logger

    def initialize(app, *args, &block)
      options = args.first || {}
      @app = app

      logger = options[:logger] || NullLogger.instance
      self.logger = logger
      begin
        if logger.level == 0 # Log set to debug level
          unless options[:enable_debugging]
            self.logger = logger.dup
            self.logger.level = 1 # info
          end
        end
      rescue NoMethodError # In case logger doesn't respond_to? :level
      end

      if options.key? :template_path
        raise "Template path should not be used. Use asset_host instead."
      end

      unless options[:asset_host]
        options[:asset_host] = Plek.current.find("assets")
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
      ENV['RAILS_ENV'] == 'development'
    end

    def skip_slimmer_param?(env)
      skip = Rack::Request.new(env).params['skip_slimmer']
      skip and skip.to_i > 0
    end

    def skip_slimmer_header?(response)
      !!response.headers[Headers::SKIP_HEADER]
    end

    def s(body)
      return body.to_s unless body.respond_to?(:each)
      b = ""
      body.each {|a| b << a }
      b
    end

    def content_length(rewritten_body)
      size = 0
      rewritten_body.each { |part| size += part.bytesize }
      size.to_s
    end

    def rewrite_response(env, response)
      request = Rack::Request.new(env)

      rewritten_body = case response.status
      when 200
        if response.headers[Headers::TEMPLATE_HEADER] == 'admin' || request.path =~ /^\/admin(\/|$)/
          @skin.admin s(response.body)
        else
          @skin.success request, response, s(response.body)
        end
      when 404
        @skin.error '404', s(response.body)
      else
        @skin.error '500', s(response.body)
      end

      rewritten_body = [rewritten_body] unless rewritten_body.respond_to?(:each)
      response.body = rewritten_body
      response.headers['Content-Length'] = content_length(response.body)

      response.finish
    end

    def strip_slimmer_headers(headers)
      headers.reject {|k, v| k =~ /\A#{Headers::HEADER_PREFIX}/ }
    end
  end
end
