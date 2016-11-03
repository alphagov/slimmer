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
      result_count:         "Result-Count",
      search_parameters:    "Search-Parameters",
      section:              "Section",
      skip:                 "Skip",
      template:             "Template",
      remove_search:        "Remove-Search",
    }

    APPLICATION_NAME_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:application_name]}"
    FORMAT_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:format]}"
    ORGANISATIONS_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:organisations]}"
    REPORT_A_PROBLEM_FORM = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:report_a_problem]}"
    WORLD_LOCATIONS_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:world_locations]}"
    PAGE_OWNER_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:page_owner]}"
    RESULT_COUNT_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:result_count]}"
    SEARCH_PATH_HEADER = "#{HEADER_PREFIX}-Search-Path"
    SEARCH_PARAMETERS_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:search_parameters]}"
    SKIP_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:skip]}"
    TEMPLATE_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:template]}"
    REMOVE_SEARCH_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:remove_search]}"

    def set_slimmer_headers(hash)
      raise InvalidHeader if (hash.keys - SLIMMER_HEADER_MAPPING.keys).any?
      SLIMMER_HEADER_MAPPING.each do |hash_key, header_suffix|
        value = hash[hash_key]
        headers["#{HEADER_PREFIX}-#{header_suffix}"] = value.to_s if value
      end
    end
  end
end
