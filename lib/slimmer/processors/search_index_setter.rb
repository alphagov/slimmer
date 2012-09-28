module Slimmer::Processors
  include ERB::Util

  class SearchIndexSetter
    def initialize(response)
      @response = response
    end

    def filter(content_document, page_template)
      if search_index && page_template.at_css('form#search')
        page_template.at_css('form#search') << hidden_input_element
      end
    end

    private

    def search_index
      @response.headers[Slimmer::Headers::SEARCH_INDEX_HEADER]
    end

    def hidden_input_element
      html = ERB.new('<input type="hidden" name="search-index" value="<%= search_index %>">').result(binding)
      Nokogiri::HTML.fragment(html)
    end
  end
end
