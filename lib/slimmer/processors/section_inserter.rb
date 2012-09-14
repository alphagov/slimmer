module Slimmer::Processors
  class SectionInserter
    def initialize(artefact)
      @artefact = artefact
    end

    def filter(src,dest)
      if @artefact and (list = dest.at_css('.header-context nav[role=navigation] ol'))
        if (section = @artefact.primary_section)
          append_tag(list, section["parent"]) if section["parent"]
          append_tag(list, section)
        end
        append_text(list, @artefact.title) if @artefact.title and @artefact.title !~ /\A\s*\z/
      end
    end

    private

    def append_tag(list, tag)
      link_node = Nokogiri::XML::Node.new('a', list)
      link_node['href'] = tag["content_with_tag"]["web_url"]
      link_node.content = tag["title"]

      list_item = Nokogiri::XML::Node.new('li', list)
      list_item.add_child(link_node)

      list.add_child(list_item)
    end

    def append_text(list, text)
      list_item = Nokogiri::XML::Node.new('li', list)
      list_item.content = text

      list.add_child(list_item)
    end
  end
end
