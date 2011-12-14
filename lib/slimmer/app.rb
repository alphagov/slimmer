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

      @skin = Skin.new options[:asset_host], options[:cache_templates], :logger => logger
    end

    def call(env)
      logger.debug "Slimmer: capturing response"
      response_array = @app.call(env)
      if response_array[1][SKIP_HEADER]
        logger.debug "Slimmer: Asked to skip slimmer via HTTP header"
        response_array
      else
        rewrite_response(env, response_array)
      end
    end

    def on_success(request,body)
      @skin.success(request, body)
    end

    def admin(request,body)
      @skin.admin(request,body)
    end

    def on_error(request, status, body)
      @skin.error(request, '500', body)
    end

    def on_404(request,body)
      @skin.error(request, '404', body)
    end

    def s(body)
      return body.to_s unless body.respond_to?(:each)
      b = ""
      body.each {|a| b << a }
      b
    end

    def rewrite_response(env,triplet)
      status, headers, app_body = triplet
      logger.debug "Slimmer: constructing request object"
      source_request = Rack::Request.new(env)
      logger.debug "Slimmer: constructing request headers object"
      request = Rack::Request.new(headers)
      content_type = headers['Content-Type'] || headers['content-type']
      logger.debug "Slimmer: Content-Type: #{content_type}"
      if content_type =~ /text\/html/
        logger.debug "Slimmer: Status code = #{status}"
        case status.to_i
        when 200
          logger.debug "Slimmer: I will rewrite this request"
          logger.debug "Slimmer: #{TEMPLATE_HEADER} = #{headers[TEMPLATE_HEADER].inspect}"
          logger.debug "Slimmer: Request path = #{source_request.path.inspect}"
          if headers[TEMPLATE_HEADER] == 'admin' || source_request.path =~ /^\/admin(\/|$)/
            logger.debug "Slimmer: Rewriting this request as an admin request"
            rewritten_body = admin(request,s(app_body))
          else
            logger.debug "Slimmer: Rewriting this request as a public request"
            rewritten_body = on_success(request,s(app_body))
          end
        when 301, 302, 304
          logger.debug "Slimmer: I will not rewrite this request"
          rewritten_body = app_body
        when 404
          logger.debug "Slimmer: Rewriting this request as a 404 error"
          rewritten_body = on_404(request,s(app_body))
        else
          logger.debug "Slimmer: Rewriting this request as a generic error"
          rewritten_body = on_error(request,status,s(app_body))
        end
      else
        logger.debug "Slimmer: I will not rewrite this request"
        rewritten_body = app_body
      end
      rewritten_body = [rewritten_body] unless rewritten_body.respond_to?(:each)
      filtered_headers = filter_headers headers
      logger.debug "Slimmer: Returning final status, headers and body"
      [status, filtered_headers, rewritten_body]
    end

    def filter_headers(header_hash)
      valid_keys = ['vary', 'set-cookie', 'location', 'content-type', 'expires', 'cache-control']
      logger.debug "Slimmer: removing headers except #{valid_keys} from #{header_hash.keys}"
      header_hash.keys.each do |key|
        header_hash.delete(key) unless valid_keys.include?(key.downcase)
      end
      logger.debug "Slimmer: filtered headers = #{header_hash.inspect}"
      header_hash
    end
  end
end
