module Slimmer::Processors
  class MetadataInserter
    def initialize(response, app_name)
      @headers = response.headers
      @app_name = app_name
    end

    def filter(_old_doc, new_doc)
      head = new_doc.at_css("head")

      # temporarily duplicate these tags with the old names to avoid deployment issues
      add_meta_tag("analytics:organisations", @headers[Slimmer::Headers::ORGANISATIONS_HEADER], head, new_doc)
      add_meta_tag("analytics:world-locations", @headers[Slimmer::Headers::WORLD_LOCATIONS_HEADER], head, new_doc)
      add_meta_tag("organisations", @headers[Slimmer::Headers::ORGANISATIONS_HEADER], head, new_doc)
      add_meta_tag("world-locations", @headers[Slimmer::Headers::WORLD_LOCATIONS_HEADER], head, new_doc)
      add_meta_tag("format", @headers[Slimmer::Headers::FORMAT_HEADER], head, new_doc)
      add_meta_tag("search-result-count", @headers[Slimmer::Headers::RESULT_COUNT_HEADER], head, new_doc)
      add_meta_tag("rendering-application", @app_name, head, new_doc)
    end

  private

    def add_meta_tag(name, content, head, doc)
      if content
        meta_node = Nokogiri::XML::Node.new("meta", doc)
        meta_node["name"] = "govuk:#{name}"
        meta_node["content"] = content

        head.add_child(meta_node)
      end
    end
  end
end
