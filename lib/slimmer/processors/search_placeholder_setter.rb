module Slimmer::Processors
  class SearchPlaceholderSetter
    def initialize(headers)
      @headers = headers
    end

    def filter(_source, template)
      if placeholder && template.at_css('form#search')
        template.at_css('form#search label').content = placeholder
        template.at_css('#site-search-text')['title'] = placeholder
      end
    end

    def placeholder
      @headers[Slimmer::Headers::SEARCH_PLACEHOLDER_HEADER]
    end
  end
end
