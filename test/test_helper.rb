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