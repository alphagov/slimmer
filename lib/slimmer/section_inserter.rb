module Slimmer
  class SectionInserter
    def filter(src,dest)
      meta_name = dest.at_css('meta[name="x-section-name"]')
      meta_link = dest.at_css('meta[name="x-section-link"]')
      list = dest.at_css('nav[role=navigation] ol')

      # FIXME: Presumably this is meant to stop us adding a 'current section'
      # link if we're missing navigation, or x-section-* meta tags.
      # It doesn't work: #at_css will return a truthy object in any case.
      if meta_name && meta_link && list
        link_node = Nokogiri::XML::Node.new('a', dest)
        link_node['href'] = meta_link['content']
        link_node.content = meta_name['content']

        list_item = Nokogiri::XML::Node.new('li', dest)
        list_item.add_child(link_node)

        list.add_child(list_item)
      end
    end
  end
end
