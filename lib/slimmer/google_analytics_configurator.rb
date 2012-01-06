require "json"

module Slimmer
  class GoogleAnalyticsConfigurator

    HEADER_MAPPING = {
      "Section"     => "X-SLIMMER-SECTION",
      "Format"      => "X-SLIMMER-FORMAT",
      "NeedID"      => "X-SLIMMER-NEED-ID",
      "Proposition" => "X-SLIMMER-PROPOSITION",
    }

    def initialize(headers)
      @headers = normalise_headers(headers)
    end

    def filter(src, dest)
      custom_vars = HEADER_MAPPING.map.with_index(1) { |(name, key), slot|
        set_custom_var(slot, name, @headers[key])
      }.compact.join("\n");

      if dest.at_css("#ga-params")
        dest.at_css("#ga-params").content += custom_vars
      end
    end

  private
    def normalise_headers(headers)
      Hash[headers.map { |k, v| [k.upcase, v] }]
    end

    def set_custom_var(slot, name, value)
      return nil unless value
      "_gaq.push(#{JSON.dump([ "_setCustomVar", slot, name, value, 3])});"
    end
  end
end

