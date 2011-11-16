require_relative '../lib/slimmer'
require 'minitest/autorun'
require 'rack/test'

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

  def self.given_response(code, body)
    define_method(:app) do
      inner_app = proc { |env|
        [code, {"Content-Type" => "text/html"}, body]
      }
      Slimmer::App.new(inner_app)
    end

    define_method(:setup) { get "/" }
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