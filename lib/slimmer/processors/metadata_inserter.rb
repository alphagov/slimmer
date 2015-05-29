module Slimmer::Processors
  class MetadataInserter
    def initialize(response, artefact, app_name)
      @headers = response.headers
      @artefact = artefact
      @app_name = app_name
    end

    def filter(src, dest)
      head = dest.at_css('head')

      if @artefact
        add_meta_tag('section', @artefact.primary_root_section["title"].downcase, head) if @artefact.primary_root_section
        add_meta_tag('need-ids', @artefact.need_ids.join(',').downcase, head) if @artefact.need_ids
      end

      add_meta_tag('analytics:organisations', @headers[Slimmer::Headers::ORGANISATIONS_HEADER], head)
      add_meta_tag('analytics:world-locations', @headers[Slimmer::Headers::WORLD_LOCATIONS_HEADER], head)
      add_meta_tag('format', @headers[Slimmer::Headers::FORMAT_HEADER], head)
      add_meta_tag('search-result-count', @headers[Slimmer::Headers::RESULT_COUNT_HEADER], head)
      add_meta_tag('rendering-application', @app_name, head)
    end

  private

    def add_meta_tag(name, content, head)
      if content
        meta_node = Nokogiri::XML::Node.new('meta', head)
        meta_node['name'] = "govuk:#{name}"
        meta_node['content'] = content

        head.add_child(meta_node)
      end
    end
  end
end
