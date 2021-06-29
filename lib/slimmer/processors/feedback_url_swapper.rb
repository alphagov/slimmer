module Slimmer::Processors
  class FeedbackURLSwapper
    def initialize(request, headers = {})
      @headers = headers
      @request = request
    end

    def filter(_src, dest)
      email_regex = /[^\s=\/?&]+(?:@|%40)[^\s=\/?&]+/

      original_url = @request.base_url + @request.fullpath
      original_url_without_pii = utf_encode(original_url.gsub(email_regex, "[email]"))
      dest.at_css(".gem-c-feedback input[name='url']").set_attribute("value", original_url_without_pii) if is_gem_layout?

      full_path = @request.fullpath
      full_path_without_pii = utf_encode(full_path.gsub(email_regex, "[email]"))
      dest.at_css(".gem-c-feedback input[name='email_survey_signup[survey_source]']").set_attribute("value", full_path_without_pii) if is_gem_layout?

      dest
    end

  private

    def utf_encode(element)
      element.is_a?(String) ? element.encode : element
    end

    def is_gem_layout?
      @headers[Slimmer::Headers::TEMPLATE_HEADER]&.starts_with?("gem_layout")
    end
  end
end
