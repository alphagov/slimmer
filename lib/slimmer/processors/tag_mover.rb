module Slimmer::Processors
  class TagMover
    def filter(src,dest)
      move_tags(src, dest, 'script', :dest_node => 'body', :keys => ['src', 'inner_html'])
      move_tags(src, dest, 'link',   :must_have => ['href'])
      move_tags(src, dest, 'meta',   :must_have => ['name', 'content'], :keys => ['name', 'content', 'http-equiv'])
      move_tags(src, dest, 'meta',   :must_have => ['property', 'content'], :keys => ['property', 'content'])
    end

    def include_tag?(node, min_attrs)
      min_attrs.inject(true) { |all_okay, attr_name| all_okay && node.has_attribute?(attr_name) }
    end

    def tag_fingerprint(node, attrs)
      attrs.collect do |attr_name|
        if attr_name == 'inner_html'
          node.content
        else
          node.has_attribute?(attr_name) ? node.attr(attr_name) : nil
        end
      end.compact.sort
    end

    def wrap_node(src, node)
      if node.previous_sibling.to_s =~ /<!--\[if[^\]]+\]><!-->/ and node.next_sibling.to_s == '<!--<![endif]-->'
        node = Nokogiri::XML::NodeSet.new(src, [node.previous_sibling, node, node.next_sibling])
      end
      node
    end

    def move_tags(src, dest, type, opts)
      comparison_attrs = opts[:keys] || opts[:must_have]
      min_attrs = opts[:must_have] || []
      already_there = dest.css(type).map { |node|
        tag_fingerprint(node, comparison_attrs)
      }.compact
      dest_node = opts[:dest_node] || 'head'

      src.css(type).each do |node|
        if include_tag?(node, min_attrs) && !already_there.include?(tag_fingerprint(node, comparison_attrs))
          node = wrap_node(src, node)
          node.remove
          dest.at_xpath("/html/#{dest_node}") << node
        end
      end
    end
  end
end
