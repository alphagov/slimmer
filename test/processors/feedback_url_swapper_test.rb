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

    env = Rack::MockRequest.env_for("https://new-example.com/new_path")
    request = Rack::Request.new(env)

    headers = { Slimmer::Headers::TEMPLATE_HEADER => "gem_layout" }

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

    env = Rack::MockRequest.env_for("https://new-example.com/new_path")
    request = Rack::Request.new(env)

    headers = { Slimmer::Headers::TEMPLATE_HEADER => "core_layout" }

    Slimmer::Processors::FeedbackURLSwapper.new(request, headers).filter(nil, template)

    assert_in template, "#test-input[value='/old_path']"
    assert_in template, "#test-input-two[value='https://example.com/old_path']"
  end

  def test_should_redact_an_email_adress_in_the_url
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

    env = Rack::MockRequest.env_for("https://new-example.com/new_path?secret@email.com")
    request = Rack::Request.new(env)

    headers = { Slimmer::Headers::TEMPLATE_HEADER => "gem_layout" }

    Slimmer::Processors::FeedbackURLSwapper.new(request, headers).filter(nil, template)

    assert_in template, "#test-input[value='/new_path?[email]']"
    assert_in template, "#test-input-two[value='https://new-example.com/new_path?[email]']"
  end

  def test_should_cope_with_a_ascii_encoded_url
    template = as_nokogiri %(
      <div class="gem-c-feedback">
        <input
          id="test-input"
          name="email_survey_signup[survey_source]"
          value="/old_path"
        >
        <input
          id="test-input-two"
          name="url"
          value="https://example.com/old_path"
        >
      </div>
    )

    # Need to use a stub as a MockRequest will throw an exception on ASCII
    # characters.
    request = stub("Rack::Request",
                   base_url: "https://example.com".force_encoding("ASCII-8BIT"),
                   fullpath: "/test?áscii=%EE%90%80".force_encoding("ASCII-8BIT"))

    headers = { Slimmer::Headers::TEMPLATE_HEADER => "gem_layout" }

    Slimmer::Processors::FeedbackURLSwapper.new(request, headers).filter(nil, template)

    assert_in template, "#test-input[value='/test?áscii=%EE%90%80']"
    assert_in template, "#test-input-two[value='https://example.com/test?áscii=%EE%90%80']"
  end

  def test_should_cope_with_no_selector_being_found
    template = as_nokogiri %(
      <div>
        <input
          id="test-input"
          name="NOT-email_survey_signup[survey_source]"
          value="/old_path"
        >
        <input
          id="test-input-two"
          name="NOT-url"
          value="https://example.com/old_path"
        >
      </div>
    )

    env = Rack::MockRequest.env_for("https://new-example.com/new_path")
    request = Rack::Request.new(env)

    headers = { Slimmer::Headers::TEMPLATE_HEADER => "gem_layout" }

    original_html = template.to_s

    Slimmer::Processors::FeedbackURLSwapper.new(request, headers).filter(nil, template)

    assert_equal original_html, template.to_s
  end
end
