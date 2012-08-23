module Slimmer::Processors
  class SectionInserter
    def initialize(artefact)
      @artefact = artefact
    end

    def filter(src,dest)
      list = dest.at_css('nav[role=navigation] ol')

      if list && (section = get_section_details)
        link_node = Nokogiri::XML::Node.new('a', dest)
        link_node['href'] = "/browse/#{section["id"]}"
        link_node.content = section["title"]

        list_item = Nokogiri::XML::Node.new('li', dest)
        list_item.add_child(link_node)

        list.add_child(list_item)
      end
    end

    def get_section_details
      return nil unless @artefact["primary_section"] and @artefact["tags"]
      base_section_id = @artefact["primary_section"].split('/').first
      @artefact["tags"].detect {|t| t["id"] == base_section_id }
    end
  end
end
