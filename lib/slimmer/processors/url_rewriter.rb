module Slimmer::Processors
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
end
