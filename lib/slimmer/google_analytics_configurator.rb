require "json"

module Slimmer
  class GoogleAnalyticsConfigurator
    PAGE_LEVEL_EVENT = 3
    HEADER_MAPPING = {
      "Section"     => "X-SLIMMER-SECTION",
      "Format"      => "X-SLIMMER-FORMAT",
      "NeedID"      => "X-SLIMMER-NEED-ID",
      "Proposition" => "X-SLIMMER-PROPOSITION",
      "ResultCount" => "X-SLIMMER-RESULT-COUNT"
    }

    def initialize(response)
      @headers = response.headers
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
    def set_custom_var(slot, name, value)
      return nil unless value
      value.downcase!
      "_gaq.push(#{JSON.dump([ "_setCustomVar", slot, name, value, PAGE_LEVEL_EVENT])});"
    end
  end
end

