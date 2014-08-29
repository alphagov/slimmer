require 'json'

module Slimmer::Processors
  class SearchParameterInserter
    def initialize(response)
      @response = response
    end

    def filter(content_document, page_template)
      search_form = page_template.at_css('form#search')
      if search_parameters && search_form
        search_parameters.each_pair do |name, value|
          # Value can either be a string or an array of values
          if value.is_a? Array
            array_name = "#{name}[]"
            value.each do |array_value|
              add_hidden_input(search_form, array_name, array_value)
            end
          else
            add_hidden_input(search_form, name, value)
          end
        end
      end
    end

    def add_hidden_input(search_form, name, value)
      element = Nokogiri::XML::Node.new('input', search_form)
      element['type'] = 'hidden'
      element['name'] = name
      element['value'] = value.to_s
      search_form.add_child(element)
    end

    def search_parameters
      @search_parameters ||= parse_search_parameters
    end

    def parse_search_parameters
      header_value = @response.headers.fetch(Slimmer::Headers::SEARCH_PARAMETERS_HEADER, "{}")
      JSON.parse(header_value)
    end
  end
end
