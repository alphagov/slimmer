module Slimmer
  module Headers
    InvalidHeader = Class.new(RuntimeError)

    HEADER_PREFIX = "X-Slimmer"

    SLIMMER_HEADER_MAPPING = {
      campaign_notification:"Campaign-Notification",
      format:               "Format",
      need_id:              "Need-ID",
      proposition:          "Proposition",
      remove_meta_viewport: "Remove-Meta-Viewport",
      result_count:         "Result-Count",
      section:              "Section",
      skip:                 "Skip",
      template:             "Template",
    }

    ARTEFACT_HEADER = "#{HEADER_PREFIX}-Artefact"
    FORMAT_HEADER = "#{HEADER_PREFIX}-Format"
    REMOVE_META_VIEWPORT = "#{HEADER_PREFIX}-Remove-Meta-Viewport"
    RESULT_COUNT_HEADER = "#{HEADER_PREFIX}-Result-Count"
    SEARCH_INDEX_HEADER = "#{HEADER_PREFIX}-Search-Index"
    SEARCH_PATH_HEADER = "#{HEADER_PREFIX}-Search-Path"
    SKIP_HEADER = "#{HEADER_PREFIX}-Skip"
    TEMPLATE_HEADER = "#{HEADER_PREFIX}-Template"

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
        if details[:parent]
          tag["parent"] = {"title" => details[:parent][:section_name],
                            "details" => {"type" => "section"},
                            "content_with_tag" => {"web_url" => details[:parent][:section_link]},
                          }
        end
        artefact["tags"] = [tag]
      end
      headers[ARTEFACT_HEADER] = artefact.to_json
    end
  end
end
