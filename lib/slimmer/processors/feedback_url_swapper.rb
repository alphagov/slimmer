module Slimmer::Processors
  class FeedbackURLSwapper
    def initialize(request, headers)
      @headers = headers
      @request = request
    end

    def filter(_src, dest)
      return dest unless is_gem_layout?

      original_url_without_pii = remove_pii(@request.base_url + @request.fullpath)
      dest.at_css(".gem-c-feedback input[name='url']").set_attribute("value", original_url_without_pii)

      full_path_without_pii = remove_pii(@request.fullpath)
      dest.at_css(".gem-c-feedback input[name='email_survey_signup[survey_source]']").set_attribute("value", full_path_without_pii)

      dest
    end

  private

    # This PII removal is also found in the [feedback component in the GOV.UK
    # Publishing Components gem](https://git.io/JcCIE), and any changes made
    # need to be kept in sync.
    def remove_pii(string)
      email_regex = /[^\s=\/?&]+(?:@|%40)[^\s=\/?&]+/
      string.dup.force_encoding("UTF-8").gsub(email_regex, "[email]")
    end

    def is_gem_layout?
      @headers[Slimmer::Headers::TEMPLATE_HEADER]&.starts_with?("gem_layout")
    end
  end
end
