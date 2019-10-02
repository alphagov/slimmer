module Slimmer::Processors
  class MetadataInserter
    def initialize(response, app_name)
      @headers = response.headers
      @app_name = app_name
    end

    def filter(_src, dest)
      head = dest.at_css('head')

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
