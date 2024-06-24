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

      if source_markup.nil? && wrapper_check?
        raise(Slimmer::SourceWrapperNotFoundError, <<~END_STRING, caller)
          Slimmer did not find the wrapper div in the source HTML.
          The following cause can be safely ignored, other need
          to be investigated. One possible cause is that the
          requested format was different from HTML e.g. JavaScript,
          but the action only supports the HTML template and layout.
          Rails only applies layouts matching the requested format,
          so the layout was not applied.
        END_STRING
      end

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
