module Slimmer
  class App
    def initialize(app, *args, &block)
      options = args.first || {}
      @app = app

      if options.key? :template_path
        raise "Template path should not be used. Use asset_host instead."
      end

      unless options[:asset_host]
        options[:asset_host] = Plek.current.find("assets")
      end

      @skin = Skin.new options[:asset_host], options[:cache_templates]
    end

    def call(env)
      response_array = @app.call(env)
      if response_array[1][SKIP_HEADER]
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
      source_request = Rack::Request.new(env)
      request = Rack::Request.new(headers)
      if headers['Content-Type'] =~ /text\/html/ || headers['content-type'] =~ /text\/html/
        case status.to_i
        when 200
          if headers[TEMPLATE_HEADER] == 'admin' || source_request.path =~ /^\/admin(\/|$)/
            rewritten_body = admin(request,s(app_body))
          else
            rewritten_body = on_success(request,s(app_body))
          end
        when 301, 302, 304
          rewritten_body = app_body
        when 404
          rewritten_body = on_404(request,s(app_body))
        else
          rewritten_body = on_error(request,status,s(app_body))
        end
      else
        rewritten_body = app_body
      end
      rewritten_body = [rewritten_body] unless rewritten_body.respond_to?(:each)
      [status, filter_headers(headers), rewritten_body]
    end

    def filter_headers(header_hash)
      valid_keys = ['vary', 'set-cookie', 'location', 'content-type', 'expires', 'cache-control']
      header_hash.keys.each do |key|
        header_hash.delete(key) unless valid_keys.include?(key.downcase)
      end
      header_hash
    end
  end
end
