module Slimmer
  module Headers
    InvalidHeader = Class.new(RuntimeError)

    HEADER_PREFIX = "X-Slimmer"

    SLIMMER_HEADER_MAPPING = {
      section:      "Section",
      need_id:      "Need-ID",
      format:       "Format",
      proposition:  "Proposition",
      result_count: "Result-Count",
      template:     "Template",
      skip:         "Skip",
    }

    TEMPLATE_HEADER = "#{HEADER_PREFIX}-Template"
    SKIP_HEADER = "#{HEADER_PREFIX}-Skip"
    SEARCH_PATH_HEADER = "#{HEADER_PREFIX}-Search-Path"
    ARTEFACT_HEADER = "#{HEADER_PREFIX}-Artefact"

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
      elsif artefact_input.respond_to?(:to_hash) # e.g. GdsApi::Response
        artefact = artefact_input.to_hash.dup
      end

      if artefact.is_a?(Hash)
        # Temporary deletions until the actions are removed from the API.
        # The actions increase the size of the artefact significantly, and will
        # only grow over time.
        #
        # We skip this when given an OpenStruct as they won't have actions etc...
        artefact.delete("actions")
        if artefact["related_items"]
          artefact["related_items"].each do |ri|
            ri["artefact"].delete("actions") if ri["artefact"]
          end
        end
      end

      headers[ARTEFACT_HEADER] = artefact.to_json
    end
  end
end
