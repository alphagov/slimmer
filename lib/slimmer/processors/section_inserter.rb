module Slimmer::Processors
  class SectionInserter
    def initialize(artefact)
      @artefact = artefact
    end

    def filter(src, dest)
      if @artefact and (list = dest.at_css('.header-context nav[role=navigation] ol'))
        if (section = @artefact.primary_section)
          sections = recurse_sections(section)
          current = sections.pop
          sections.each do |section|
            append_tag(list, section)
          end
          append_tag(list, current, :strong => true)
        end
      end
    end

    private

    def recurse_sections(section, current = nil)
      current = [section] unless current

      if section['parent']
        current.unshift(section['parent'])
        current = recurse_sections(section['parent'], current)
      end
      current
    end

    def append_tag(list, tag, opts = {})
      link_node = Nokogiri::XML::Node.new('a', list)
      link_node['href'] = tag["content_with_tag"]["web_url"]
      link_node.content = tag["title"]

      list_item = Nokogiri::XML::Node.new('li', list)
      if opts[:strong]
        strong = Nokogiri::XML::Node.new('strong', list)
        strong.add_child(link_node)
        list_item.add_child(strong)
      else
        list_item.add_child(link_node)
      end

      list.add_child(list_item)
    end
  end
end
