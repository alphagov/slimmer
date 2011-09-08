require 'nokogiri'
require 'open-uri'

module Slimmer

  class App
    
    def initialize(app,options = {})
      @app = app
      @skin = Skin.new(options[:template_host])
    end

    def call(env)
      status,env2,body = @app.call(env)
      rewrite_response(env,[status,env2,body])
    end

    def on_success(request,body)
      @skin.success(request, body)
    end

    def admin(request,body)
      @skin.admin(request,body)
    end

    def on_error(request,status, body)
      @skin.error(request, '500')
    end

    def on_404(request,body)
      @skin.error(request, '404')
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
          if source_request.path =~ /^\/admin(\/|$)/
            rewritten_body = admin(request,s(app_body))
          else
            rewritten_body = on_success(request,s(app_body))
          end
        when 301, 302, 304
          rewritten_body = app_body
        when 404
          rewritten_body = on_404(request,s(app_body))
        else
          rewritten_body = on_error(request,status, s(app_body))
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

  class UrlRewriter
    
    def initialize(request)
      @request = request
    end

    def filter(src,dest)
      rewrite_document src 
    end

    def rewrite_document(doc)
      rewrite_nodes doc.css('body img'),'src' 
      rewrite_nodes doc.css('script'),'src' 
      rewrite_nodes doc.css('link'),'href' 
    end

    def rewrite_nodes(nodes,attr)
      nodes.each do |node|
        next unless node.attr(attr)
        node_uri = URI.parse(node.attr(attr))
        node.attribute(attr).value = rewrite_url(node_uri).to_s
      end
    end

    def rewrite_url(uri)
      unless uri.absolute?
        uri.scheme = @request.scheme
        if @request.host =~ /:/
          host,port = @request.host.split(":")
          uri.host = host
          uri.port = port
        else
          uri.host =   @request.host
          uri.port =   @request.port
        end
      end   
      uri
    end
  end

  class TitleInserter
    def filter(src,dest)
      title = src.at_css('head title')
      head  = dest.at_xpath('/html/head')
      if head && title
        insert_title(title,head)
      end
    end
    
    def insert_title(title, head)
      if head.at_css('title').nil? 
        head.first_element_child.nil? ? head << title : head.first_element_child.before(title)
      else
        head.at_css('title').replace(title)
      end
    end
  end

  class TagMover
    def filter(src,dest)
      move_tags(src, dest, 'script', :must_have => ['src'])
      move_tags(src, dest, 'link',   :must_have => ['href'])
      move_tags(src, dest, 'meta',   :must_have => ['name', 'content'], :keys => ['name', 'content', 'http-equiv'])
    end

    def include_tag?(node, min_attrs)
      min_attrs.inject(true) { |all_okay, attr_name| all_okay && node.has_attribute?(attr_name) }
    end

    def tag_fingerprint(node, attrs)
      attrs.collect do |attr_name| 
        node.has_attribute?(attr_name) ? node.attr(attr_name) : nil
      end.compact.sort
    end

    def move_tags(src, dest, type, opts)
      comparison_attrs = opts[:keys] || opts[:must_have]
      min_attrs = opts[:must_have]
      already_there = dest.css(type).map { |node|
        tag_fingerprint(node, comparison_attrs)
      }.compact

      src.css(type).each do |node|
        if include_tag?(node, min_attrs) && !already_there.include?(tag_fingerprint(node, comparison_attrs))
          node.remove
          dest.at_xpath('/html/head') << node
        end
      end
    end
  end

  class BodyInserter
    def initialize(path='#wrapper')
      @path = path
    end
    
    def filter(src,dest)
      body = src.fragment(src.at_css(@path)) 
      dest.at_css(@path).replace(body)
    end
  end

  class AdminTitleInserter
    def filter(src,dest)
      title = src.at_css('#site-title')
      head  = dest.at_css('.gds-header h2')
      if head && title
        head.content = title.content
        title.remove
      end
    end
  end

  class FooterRemover
    def filter(src,dest)
      footer = src.at_css("#footer")
      footer.remove if footer
    end
  end

  class Skin

    def initialize(asset_host)
      @asset_host = asset_host
    end

    def template(template)
      open("#{@asset_host}/#{template}.html", "r:UTF-8").read
    end

    def unparse_esi(doc)
      ## HTML doesn't really have namespaces, and nokogiri's
      ## default behaviour is to strip the namespace, but to
      ## leave the tag name intact. Ugly hack here to reverse
      ## that for ESI includes
      doc.gsub("<include","<esi:include").gsub(/><\/(esi:)?include>/, ' />')
    end

    def error(request,template)
      processors = [
        TitleInserter.new()
      ]
      self.process(processors,"<html></html>",template(template))
    end

    def process(processors,body,template)
      src = Nokogiri::HTML.parse(body.to_s)
      dest = Nokogiri::HTML.parse(template)

      processors.each do |p|
        p.filter(src,dest)
      end
      
      return unparse_esi(dest.to_html)
    end
    
    def admin(request,body)
      processors = [
        TitleInserter.new(),
        TagMover.new(),
        AdminTitleInserter.new,
        FooterRemover.new,
        BodyInserter.new(),
      ]
      self.process(processors,body,template('admin'))
    end
    
    def success(request,body)
      
      processors = [
        TitleInserter.new(),
        TagMover.new(),
        BodyInserter.new()
      ]

      self.process(processors,body,template('wrapper'))
    end
  end


end
