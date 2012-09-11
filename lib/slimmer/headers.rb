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
      artefact = artefact_input.dup
      artefact["details"].delete("parts") if artefact["details"].has_key?("parts") # Alex Tomlins said something about nginx limits?
      headers[ARTEFACT_HEADER] = artefact.to_json
    end
  end
end
