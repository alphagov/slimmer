module Slimmer
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

    def wrap_node(node)
      wrap = node.delete('slimmer-wrap-with')
      "<!--[if #{wrap}]>-->#{node.to_s}<!--<![endif]-->"
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
          if node['slimmer-wrap-with']
            node = wrap_node(node)
          end
          dest.at_xpath('/html/head') << node
        end
      end
    end
  end
end
