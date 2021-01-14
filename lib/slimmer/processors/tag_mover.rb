module Slimmer::Processors
  class TagMover
    def filter(src, dest)
      move_tags(src, dest, "link",   must_have: %w[href])
      move_tags(src, dest, "meta",   must_have: %w[name content], keys: %w[name content http-equiv], insertion_location: :top)
      move_tags(src, dest, "meta",   must_have: %w[property content], keys: %w[property content], insertion_location: :top)
      move_tags(src, dest, "base",   must_have: %w[href])
      move_tags(src, dest, "script", keys: %w[src inner_html], head_if_attributes: %w[async defer])
    end

    def include_tag?(node, min_attrs)
      min_attrs.inject(true) { |all_okay, attr_name| all_okay && node.has_attribute?(attr_name) }
    end

    def tag_fingerprint(node, attrs)
      collected_attrs = attrs.collect do |attr_name|
        if attr_name == "inner_html"
          node.content
        else
          node.has_attribute?(attr_name) ? node.attr(attr_name) : nil
        end
      end

      collected_attrs.compact.sort
    end

    def wrap_node(src, node)
      if node.previous_sibling.to_s =~ /<!--\[if[^\]]+\]><!-->/ && node.next_sibling.to_s == "<!--<![endif]-->"
        node = Nokogiri::XML::NodeSet.new(src, [node.previous_sibling, node, node.next_sibling])
      end
      node
    end

    def head_or_body(node, head_if_attributes)
      if head_if_attributes.any? { |attribute| node.has_attribute?(attribute) }
        "head"
      else
        "body"
      end
    end

    def move_tags(src, dest, type, opts)
      comparison_attrs = opts[:keys] || opts[:must_have]
      min_attrs = opts[:must_have] || []
      head_if_attributes = opts[:head_if_attributes] || []
      dest_node = "head"
      already_there = dest.css(type).map { |node|
        tag_fingerprint(node, comparison_attrs)
      }.compact

      src.css(type).each do |node|
        next unless include_tag?(node, min_attrs) && !already_there.include?(tag_fingerprint(node, comparison_attrs))

        node = wrap_node(src, node)
        if head_if_attributes.any?
          dest_node = head_or_body(node, head_if_attributes)
          insert_at_top = true if dest_node == "head"
        end
        node.remove

        if opts[:insertion_location] == :top || insert_at_top
          dest.at_xpath("/html/#{dest_node}").prepend_child(node)
        else
          dest.at_xpath("/html/#{dest_node}") << node
        end
      end
    end
  end
end
