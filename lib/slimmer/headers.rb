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
    RESULT_COUNT_HEADER = "#{HEADER_PREFIX}-Result-Count"

    def set_slimmer_headers(hash)
      raise InvalidHeader if (hash.keys - SLIMMER_HEADER_MAPPING.keys).any?
      SLIMMER_HEADER_MAPPING.each do |hash_key, header_suffix|
        value = hash[hash_key]
        headers["#{HEADER_PREFIX}-#{header_suffix}"] = value.to_s if value
      end
    end

    def set_slimmer_artefact(artefact_input)
      artefact = artefact_input.dup
      headers[ARTEFACT_HEADER] = artefact.to_json
    end

    def set_slimmer_dummy_artefact(details = {})
      artefact = {}
      artefact["title"] = details[:title] if details[:title]
      if details[:section_name] and details[:section_link]
        tag = {
          "title" => details[:section_name],
          "details" => {"type" => "section"},
          "content_with_tag" => {"web_url" => details[:section_link]},
        }
        artefact["tags"] = [tag]
      end
      headers[ARTEFACT_HEADER] = artefact.to_json
    end
  end
end
