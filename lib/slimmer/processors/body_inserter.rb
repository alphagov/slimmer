module Slimmer::Processors
  class BodyInserter
    def initialize(source_id = "wrapper", destination_id = "wrapper", headers = {})
      @source_selector = "##{source_id}"
      @destination_selector = "##{destination_id}"
      @headers = headers
    end

    def filter(src, dest)
      source_markup = src.at_css(@source_selector)
      destination_markup = dest.at_css(@destination_selector)

      raise(Slimmer::SourceWrapperNotFoundError, "Source wrapper div not found", caller) if source_markup.nil? && wrapper_check?

      css_classes = []
      css_classes << source_markup.attributes["class"].to_s.split(/ +/) if source_markup.has_attribute?("class")
      css_classes << destination_markup.attributes["class"].to_s.split(/ +/) if destination_markup.has_attribute?("class")

      body = Nokogiri::HTML.fragment(source_markup.to_html)
      dest.at_css(@destination_selector).replace(body)
      dest.at_css(@destination_selector).set_attribute("class", css_classes.flatten.uniq.join(" ")) if is_gem_layout? && css_classes.any?
    end

  private

    def is_gem_layout?
      @headers[Slimmer::Headers::TEMPLATE_HEADER]&.start_with?("gem_layout")
    end

    def wrapper_check?
      ENV["SLIMMER_WRAPPER_CHECK"] == "true"
    end
  end
end
