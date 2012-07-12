require "gds_api/exceptions"

module Slimmer
  class App
    attr_accessor :logger
    private :logger=, :logger

    def initialize(app, *args, &block)
      options = args.first || {}
      @app = app

      logger = options[:logger] || NullLogger.instance
      self.logger = logger

      if options.key? :template_path
        raise "Template path should not be used. Use asset_host instead."
      end

      unless options[:asset_host]
        options[:asset_host] = Plek.current.find("assets")
      end

      @skin = Skin.new options.merge(logger: logger)
    end

    def call(env)
      logger.debug "Slimmer: capturing response"
      backend_response = @app.call(env)

      if in_development? and skip_slimmer_param?(env)
        logger.debug "Slimmer: Asked to skip slimmer via skip_slimmer param"
        return backend_response
      elsif skip_slimmer_header?(backend_response)
        logger.debug "Slimmer: Asked to skip slimmer via HTTP header"
        return backend_response
      else
        rewrite_response(env, backend_response)
      end
    end

    def in_development?
      ENV['RAILS_ENV'] == 'development'
    end

    def skip_slimmer_param?(env)
      skip = Rack::Request.new(env).params['skip_slimmer']
      skip and skip.to_i > 0
    end

    def skip_slimmer_header?(backend_response)
      !! backend_response[1][SKIP_HEADER]
    end

    def on_success(request, response, body)
      @skin.success(request, response, body)
    end

    def admin(body)
      @skin.admin(body)
    end

    def on_error(body)
      @skin.error('500', body)
    end

    def on_404(body)
      @skin.error('404', body)
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

    def rewrite_response(env, response_to_skin)
      response = Rack::Response.new(response_to_skin[2], response_to_skin[0], response_to_skin[1])
      request = Rack::Request.new(env)

      rewritten_body = if response.content_type =~ /text\/html/
        case response.status
        when 200
          if response.headers[TEMPLATE_HEADER] == 'admin' || request.path =~ /^\/admin(\/|$)/
            admin(s(response.body))
          else
            on_success(request, response, s(response.body))
          end
        when 301, 302, 304
          response.body
        when 404
          on_404(s(response.body))
        else
          on_error(s(response.body))
        end
      else
        response.body
      end

      rewritten_body = [rewritten_body] unless rewritten_body.respond_to?(:each)
      response.body = rewritten_body
      response.headers['Content-Length'] = content_length(response.body)

      response.finish

    rescue GdsApi::TimedOutException
      [503, {"Content-Type" => "text/plain"}, ["GDS API request timed out."]]
    end
  end
end
