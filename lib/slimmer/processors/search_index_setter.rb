require 'uri'

module Slimmer::Processors
  include ERB::Util

  class SearchIndexSetter
    def initialize(response)
      @response = response
    end

    def filter(content_document, page_template)
      if search_index && (form = page_template.at_css('form#search'))
        uri = URI(form['action'])
        uri.fragment = search_index_fragment
        form['action'] = uri.to_s
      end
    end

    private

    def search_index_fragment
      "#{search_index}-results"
    end

    def search_index
      @response.headers[Slimmer::Headers::SEARCH_INDEX_HEADER]
    end
  end
end
