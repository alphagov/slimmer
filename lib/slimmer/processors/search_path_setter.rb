module Slimmer::Processors
  class SearchPathSetter
    def initialize(response)
      @response = response
    end

    def filter(content_document, page_template)
      if search_scope && page_template.at_css('form#search')
        page_template.at_css('form#search').attributes["action"].value = search_scope
      end
    end

    def search_scope
      @response.headers[Slimmer::SEARCH_PATH_HEADER]
    end
  end
end
