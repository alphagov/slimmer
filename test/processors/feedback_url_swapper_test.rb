require "test_helper"

class FeedbackURLSwapperTest < MiniTest::Test
  def test_should_replace_input_url_values_in_gem_layout
    template = as_nokogiri %(
      <html>
        <body>
          <div class="gem-c-feedback">
            <input
              id="test-input"
              type="hidden"
              name="email_survey_signup[survey_source]"
              value="/old_path"
            >
            <input
              id="test-input-two"
              type="hidden"
              name="url"
              value="https://example.com/old_path"
            >
          </div>
        </body>
      </html>
    )

    request = {}

    def request.base_url
      "https://new-example.com"
    end

    def request.fullpath
      "/new_path"
    end

    headers = {
      Slimmer::Headers::TEMPLATE_HEADER => "gem_layout",
    }

    Slimmer::Processors::FeedbackURLSwapper.new(request, headers).filter(nil, template)

    assert_in template, "#test-input[value='/new_path']"
    assert_in template, "#test-input-two[value='https://new-example.com/new_path']"
  end

  def test_should_not_replace_input_url_values_when_not_gem_layout
    template = as_nokogiri %(
      <html>
        <body>
          <div class="gem-c-feedback">
            <input
              id="test-input"
              type="hidden"
              name="email_survey_signup[survey_source]"
              value="/old_path"
            >
            <input
              id="test-input-two"
              type="hidden"
              name="url"
              value="https://example.com/old_path"
            >
          </div>
        </body>
      </html>
    )

    request = {}

    def request.base_url
      "https://new-example.com"
    end

    def request.fullpath
      "/new_path"
    end

    headers = {
      Slimmer::Headers::TEMPLATE_HEADER => "core_layout",
    }

    Slimmer::Processors::FeedbackURLSwapper.new(request, headers).filter(nil, template)

    assert_in template, "#test-input[value='/old_path']"
    assert_in template, "#test-input-two[value='https://example.com/old_path']"
  end
end
