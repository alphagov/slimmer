module Slimmer
  module Headers
    InvalidHeader = Class.new(RuntimeError)

    SLIMMER_HEADER_MAPPING = {
      section:     "Section",
      need_id:     "Need-ID",
      format:      "Format",
      proposition: "Proposition",
      template:    "Template",
      skip:        "Skip",
    }

    def set_slimmer_headers(hash)
      raise InvalidHeader if (hash.keys - SLIMMER_HEADER_MAPPING.keys).any?
      SLIMMER_HEADER_MAPPING.each do |hash_key, header_suffix|
        value = hash[hash_key]
        headers["X-Slimmer-#{header_suffix}"] = value.to_s if value
      end
    end
  end
end
