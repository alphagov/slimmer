module Slimmer
  module Headers
    InvalidHeader = Class.new(RuntimeError)

    HEADER_PREFIX = "X-Slimmer"

    SLIMMER_HEADER_MAPPING = {
      application_name:     "Application-Name",
      format:               "Format",
      page_owner:           "Page-Owner",
      organisations:        "Organisations",
      report_a_problem:     "Report-a-Problem",
      world_locations:      "World-Locations",
      remove_meta_viewport: "Remove-Meta-Viewport",
      result_count:         "Result-Count",
      search_parameters:    "Search-Parameters",
      section:              "Section",
      skip:                 "Skip",
      template:             "Template",
    }

    APPLICATION_NAME_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:application_name]}"
    ARTEFACT_HEADER = "#{HEADER_PREFIX}-Artefact"
    FORMAT_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:format]}"
    ORGANISATIONS_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:organisations]}"
    REPORT_A_PROBLEM_FORM = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:report_a_problem]}"
    WORLD_LOCATIONS_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:world_locations]}"
    PAGE_OWNER_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:page_owner]}"
    REMOVE_META_VIEWPORT = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:remove_meta_viewport]}"
    RESULT_COUNT_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:result_count]}"
    SEARCH_PATH_HEADER = "#{HEADER_PREFIX}-Search-Path"
    SEARCH_PARAMETERS_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:search_parameters]}"
    SKIP_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:skip]}"
    TEMPLATE_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:template]}"

    def set_slimmer_headers(hash)
      raise InvalidHeader if (hash.keys - SLIMMER_HEADER_MAPPING.keys).any?
      SLIMMER_HEADER_MAPPING.each do |hash_key, header_suffix|
        value = hash[hash_key]
        headers["#{HEADER_PREFIX}-#{header_suffix}"] = value.to_s if value
      end
    end

    def set_slimmer_artefact(artefact_input)
      if artefact_input.is_a?(Hash) or artefact_input.is_a?(OpenStruct)
        artefact = artefact_input.dup
      elsif artefact_input.respond_to?(:to_hash)
        artefact = artefact_input.to_hash
      end
      yield artefact if block_given?
      headers[ARTEFACT_HEADER] = artefact.to_json
    end

    def set_slimmer_artefact_overriding_section(artefact_input, details = {})
      set_slimmer_artefact(artefact_input) do |artefact|
        if tag = slimmer_section_tag_for_details(details)
          artefact["tags"] = [tag] + (artefact["tags"] || [])
        end
      end
    end

    def set_slimmer_dummy_artefact(details = {})
      set_slimmer_artefact({}) do |artefact|
        artefact["title"] = details[:title] if details[:title]
        if tag = slimmer_section_tag_for_details(details)
          artefact["tags"] = [tag]
        end
      end
    end

    def slimmer_section_tag_for_details(details)
      if details[:section_name] and details[:section_link]
        tag = {
          "title" => details[:section_name],
          "details" => {"type" => "section"},
          "content_with_tag" => {"web_url" => details[:section_link]},
        }
        if details[:parent]
          tag["parent"] = slimmer_section_tag_for_details(details[:parent])
        end
        tag
      end
    end
  end
end
