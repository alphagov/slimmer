require "json"

module Slimmer::Processors
  class SearchParameterInserter
    def initialize(response)
      @response = response
    end

    def filter(_old_doc, new_doc)
      search_form = new_doc.at_css("form#search")
      if search_parameters && search_form
        search_parameters.each_pair do |name, value|
          # Value can either be a string or an array of values
          if value.is_a? Array
            array_name = "#{name}[]"
            value.each do |array_value|
              add_hidden_input(search_form, array_name, array_value, new_doc)
            end
          else
            add_hidden_input(search_form, name, value, new_doc)
          end
        end
      end
    end

    def add_hidden_input(search_form, name, value, doc)
      element = Nokogiri::XML::Node.new("input", doc)
      element["type"] = "hidden"
      element["name"] = name
      element["value"] = value.to_s
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
