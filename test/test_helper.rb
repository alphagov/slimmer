require_relative "../lib/slimmer"
require "minitest/autorun"
require "rack/test"
require "json"
require "logger"

MiniTest::Test.class_eval do
  def as_nokogiri(html_string)
    Nokogiri::HTML.parse(html_string.strip)
  end

  def assert_in(template, selector, content = nil, message = nil)
    message ||= "Expected to find #{content ? "#{content.inspect} at " : ''}#{selector.inspect} in the output template"

    assert template.at_css(selector), "#{message}, but selector not found."

    if content
      assert_equal content, template.at_css(selector).inner_html.to_s, message
    end
  end

  def assert_not_in(template, selector, message = "didn't expect to find #{selector}")
    refute template.at_css(selector), message
  end

  def allowing_real_web_connections
    WebMock.allow_net_connect!
    result = yield
    WebMock.disable_net_connect!
    result
  end
end

require "webmock/minitest"
WebMock.disable_net_connect!
Slimmer.cache = Slimmer::NoCache.new

class SlimmerIntegrationTest < MiniTest::Test
  include Rack::Test::Methods

  # given_response can either be called from a setup method, or in the class scope.
  # The setup method variant is necessary if you want to pass variables into the call that
  # are created in higher setup methods.
  def self.given_response(code, body, headers = {}, app_options = {})
    define_method(:setup) do
      super()
      given_response(code, body, headers, app_options)
    end
  end

  def given_response(code, body, headers = {}, app_options = {})
    self.class.class_eval do
      remove_method(:app) if method_defined?(:app)

      define_method(:app) do
        inner_app = proc { |_env|
          [code, { "Content-Type" => "text/html" }.merge(headers), body]
        }
        Slimmer::App.new inner_app, { asset_host: "http://template.local" }.merge(app_options)
      end
    end

    use_templates if code == 200
    fetch_page
  end

  def fetch_page
    get "/"
  end

  def use_templates
    templates = %w[gem_layout]

    templates.each do |template_name|
      template = File.read File.dirname(__FILE__) + "/fixtures/#{template_name}.html.erb"
      stub_request(:get, "http://template.local/templates/#{template_name}.html.erb")
      .to_return(body: template)
    end
  end

private

  def assert_not_rendered_in_template(content)
    refute_match(
      /#{Regexp.escape(content)}/,
      last_response.body,
    )
  end

  # content can be a string or a Regexp
  def assert_rendered_in_template(selector, content = nil, message = nil)
    message ||= if content
                  "Expected to find #{content.inspect} at #{selector.inspect} in the output template"
                else
                  "Expected to find #{selector.inspect} in the output template"
                end

    matched_elements = Nokogiri::HTML.parse(last_response.body).css(selector)
    assert !matched_elements.empty?, "#{message}, but selector not found."

    if content
      inner_htmls = matched_elements.map(&:inner_html)
      found_match = inner_htmls.grep(content).any? # grep matches strings or Regexps
      assert found_match, message + ". The selector was found but with different content: \"#{inner_htmls.join('", ')}\""
    end
  end

  def assert_no_selector(selector, message = nil)
    message ||= "Expected not to find #{selector.inspect}, but did"
    assert_nil Nokogiri::HTML.parse(last_response.body).at_css(selector), message
  end
end
