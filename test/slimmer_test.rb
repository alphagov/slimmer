require "test_helper"

class TestSlimmer < MiniTest::Unit::TestCase
  def test_template_can_be_loaded
    s = Slimmer::Skin.new
    assert s.load_template('wrapper')
  end
end