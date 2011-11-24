require_relative '../lib/slimmer'
require 'minitest/autorun'
require 'rack/test'
require 'webmock/minitest'

WebMock.disable_net_connect!

class MiniTest::Unit::TestCase
  def as_nokogiri(html_string)
    Nokogiri::HTML.parse(html_string.strip)
  end

  def assert_in(template, selector, content, message=nil)
    assert_equal content, template.at_css(selector).inner_html.to_s, message
  end
end

class SlimmerIntegrationTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def self.given_response(code, body, headers={})
    define_method(:app) do
      inner_app = proc { |env|
        [code, headers.merge("Content-Type" => "text/html"), body]
      }
      Slimmer::App.new inner_app, :asset_host => "http://template.local"
    end

    define_method :teardown do
      WebMock.reset!
    end

    define_method(:setup) do
      template_name = case code
      when 200 then 'wrapper'
      when 404 then '404'
      else          '500'
      end

      template = File.read File.dirname(__FILE__) + "/fixtures/#{template_name}.html.erb"
      stub_request(:get, "http://template.local/templates/#{template_name}.html.erb").
        to_return(:body => template)
      get "/"
    end
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
    assert element, message
    assert_equal content, element.inner_html.to_s, message if content
  end
end
