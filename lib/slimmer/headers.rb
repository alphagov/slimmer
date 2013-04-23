module Slimmer
  module Headers
    InvalidHeader = Class.new(RuntimeError)

    HEADER_PREFIX = "X-Slimmer"

    SLIMMER_HEADER_MAPPING = {
      beta:                 "Beta",
      campaign_notification:"Campaign-Notification",
      format:               "Format",
      need_id:              "Need-ID",
      proposition:          "Proposition",
      organisations:        "Organisations",
      remove_meta_viewport: "Remove-Meta-Viewport",
      result_count:         "Result-Count",
      section:              "Section",
      skip:                 "Skip",
      template:             "Template",
    }

    ARTEFACT_HEADER = "#{HEADER_PREFIX}-Artefact"
    BETA_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:beta]}"
    CAMPAIGN_NOTIFICATION = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:campaign_notification]}"
    FORMAT_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:format]}"
    ORGANISATIONS_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:organisations]}"
    REMOVE_META_VIEWPORT = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:remove_meta_viewport]}"
    RESULT_COUNT_HEADER = "#{HEADER_PREFIX}-#{SLIMMER_HEADER_MAPPING[:result_count]}"
    SEARCH_INDEX_HEADER = "#{HEADER_PREFIX}-Search-Index"
    SEARCH_PATH_HEADER = "#{HEADER_PREFIX}-Search-Path"
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
          tag["parent"] = {"title" => details[:parent][:section_name],
                            "details" => {"type" => "section"},
                            "content_with_tag" => {"web_url" => details[:parent][:section_link]},
                          }
        end
        tag
      end
    end
  end
end
