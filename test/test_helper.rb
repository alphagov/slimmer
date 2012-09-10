require_relative '../lib/slimmer'
require 'minitest/autorun'
require 'minitest/unit'
require 'rack/test'
require 'webmock/minitest'
require 'json'
require 'logger'
require 'mocha'

WebMock.disable_net_connect!
ENV['FACTER_govuk_platform'] = 'test'

class MiniTest::Unit::TestCase
  def as_nokogiri(html_string)
    Nokogiri::HTML.parse(html_string.strip)
  end

  def assert_in(template, selector, content=nil, message=nil)
    message ||= "Expected to find #{content ? "#{content.inspect} at " : ""}#{selector.inspect} in the output template"

    assert template.at_css(selector), message + ", but selector not found."

    if content
      assert_equal content, template.at_css(selector).inner_html.to_s, message
    end
  end

  def assert_not_in(template, selector, message="didn't expect to find #{selector}")
    refute template.at_css(selector), message
  end

  def allowing_real_web_connections(&block)
    WebMock.allow_net_connect!
    result = yield
    WebMock.disable_net_connect!
    result
  end
end

class SlimmerIntegrationTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  # given_response can either be called from a setup method, or in the class scope.
  # The setup method variant is necessary if you want to pass variables into the call that
  # are created in higher setup methods.
  def self.given_response(code, body, headers={}, app_options={})
    define_method(:setup) do
      super()
      given_response(code, body, headers, app_options)
    end
  end

  def given_response(code, body, headers={}, app_options={})
    self.class.class_eval do
      define_method(:app) do
        inner_app = proc { |env|
          [code, {"Content-Type" => "text/html"}.merge(headers), body]
        }
        Slimmer::App.new inner_app, {asset_host: "http://template.local"}.merge(app_options)
      end
    end

    template_name = case code
    when 200 then 'wrapper'
    when 404 then '404'
    else          '500'
    end

    use_template(template_name)
    use_template('related.raw')
    use_template('report_a_problem.raw')

    fetch_page
  end

  def fetch_page
    get "/"
  end

  def use_template(template_name)
    template = File.read File.dirname(__FILE__) + "/fixtures/#{template_name}.html.erb"
    stub_request(:get, "http://template.local/templates/#{template_name}.html.erb").
      to_return(:body => template)
  end

  private

  def assert_not_rendered_in_template(content)
    refute_match /#{Regexp.escape(content)}/, last_response.body
  end

  def assert_rendered_in_template(selector, content=nil, message=nil)
    unless message
      if content
        message = "Expected to find #{content.inspect} at #{selector.inspect} in the output template"
      else
        message = "Expected to find #{selector.inspect} in the output template"
      end
    end
    element = Nokogiri::HTML.parse(last_response.body).at_css(selector)
    assert element, message + ", but selector not found."
    if content
      message << ". But found #{element.inner_html.to_s}"
      if content.is_a?(Regexp)
        assert_match content, element.inner_html.to_s, message
      else
        assert_equal content, element.inner_html.to_s, message
      end
    end
  end

  def assert_no_selector(selector, message=nil)
    message ||= "Expected not to find #{selector.inspect}, but did"
    assert_nil Nokogiri::HTML.parse(last_response.body).at_css(selector), message
  end
end
