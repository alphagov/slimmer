module Slimmer
  # @api public
  module Headers
    # @private
    InvalidHeader = Class.new(RuntimeError)

    # @private
    HEADER_PREFIX = "X-Slimmer".freeze

    # @private
    SLIMMER_HEADER_MAPPING = {
      application_name: "Application-Name",
      format: "Format",
      page_owner: "Page-Owner",
      organisations: "Organisations",
      world_locations: "World-Locations",
      result_count: "Result-Count",
      search_parameters: "Search-Parameters",
      section: "Section",
      skip: "Skip",
      template: "Template",
      remove_search: "Remove-Search",
      show_accounts: "Show-Accounts",
    }.freeze

    # @private
    APPLICATION_NAME_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:application_name]}".freeze

    # @private
    FORMAT_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:format]}".freeze

    # @private
    ORGANISATIONS_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:organisations]}".freeze

    # @private
    WORLD_LOCATIONS_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:world_locations]}".freeze

    # @private
    PAGE_OWNER_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:page_owner]}".freeze

    # @private
    RESULT_COUNT_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:result_count]}".freeze

    # @private
    SEARCH_PATH_HEADER = "#{HEADER_PREFIX}-Search-Path".freeze

    # @private
    SEARCH_PARAMETERS_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:search_parameters]}".freeze

    # @private
    SKIP_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:skip]}".freeze

    # @private
    TEMPLATE_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:template]}".freeze

    # @private
    REMOVE_SEARCH_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:remove_search]}".freeze

    # @private
    SHOW_ACCOUNTS_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:show_accounts]}".freeze

    # Set the "slimmer headers" to configure the page
    #
    # @param hash [Hash] the options
    # @option hash [String] application_name
    # @option hash [String] format
    # @option hash [String] organisations
    # @option hash [String] page_owner
    # @option hash [String] remove_search
    # @option hash [String] result_count
    # @option hash [String] search_parameters
    # @option hash [String] section
    # @option hash [String] show_accounts
    # @option hash [String] skip
    # @option hash [String] template
    # @option hash [String] world_locations
    def set_slimmer_headers(hash)
      raise InvalidHeader if (hash.keys - SLIMMER_HEADER_MAPPING.keys).any?

      SLIMMER_HEADER_MAPPING.each do |hash_key, header_suffix|
        value = hash[hash_key]
        headers["#{HEADER_PREFIX}-#{header_suffix}"] = value.to_s if value
      end
    end
  end
end
