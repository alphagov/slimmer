require 'uri'

module Slimmer::Processors
  include ERB::Util

  class SearchIndexSetter
    def initialize(response_headers)
      @headers = response_headers
    end

    def filter(content_document, page_template)
      if search_index && (form = page_template.at_css('form#search'))
        input_html = Nokogiri::HTML.fragment(tab_input_tag)
        form.add_child(input_html)
      end
    end

    private

    def tab_input_tag
      %Q{<input type="hidden" name="tab" value="#{search_index_tab}">}
    end

    def search_index_tab
      "#{search_index}-results"
    end

    def search_index
      @headers[Slimmer::Headers::SEARCH_INDEX_HEADER]
    end
  end
end
