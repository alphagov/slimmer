require "json"

module Slimmer::Processors
  class GoogleAnalyticsConfigurator
    PAGE_LEVEL_EVENT = 3

    def initialize(response, artefact)
      @headers = response.headers
      @artefact = artefact
    end

    def filter(src, dest)
      custom_vars = []
      if @artefact
        custom_vars << set_custom_var(1, "Section", @artefact.primary_root_section["title"].downcase) if @artefact.primary_root_section
        custom_vars << set_custom_var(3, "NeedID", @artefact.need_id.downcase)
        custom_vars << set_custom_var(4, "Proposition", (@artefact.business_proposition ? 'business' : 'citizen')) unless @artefact.business_proposition.nil?
        custom_vars << set_custom_var(9, "Organisations", @artefact.organisations) unless @artefact.organisations.nil?
      end
      custom_vars << set_custom_var(2, "Format", @headers[Slimmer::Headers::FORMAT_HEADER].downcase)
      custom_vars << set_custom_var(5, "ResultCount", @headers[Slimmer::Headers::RESULT_COUNT_HEADER].downcase)

      if dest.at_css("#ga-params")
        dest.at_css("#ga-params").content += custom_vars.compact.join("\n")
      end
    end

  private
    def set_custom_var(slot, name, value)
      return nil unless value
      response = "_gaq.push(#{JSON.dump([ "_setCustomVar", slot, name, value, PAGE_LEVEL_EVENT])});\n"
      response + "GOVUK.Analytics.#{name} = \"#{value}\";"
    end
  end
end

