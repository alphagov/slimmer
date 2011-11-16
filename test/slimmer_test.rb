require_relative '../lib/slimmer'
require 'minitest/autorun'

class TestSlimmer < MiniTest::Unit::TestCase
  def test_template_can_be_loaded
    s = Slimmer::Skin.new
    assert s.load_template('wrapper')
  end
end