require_relative '../lib/slimmer'
require 'minitest/autorun'

class MiniTest::Unit::TestCase
  def as_nokogiri(html_string)
    Nokogiri::HTML.parse(html_string.strip)
  end
end