require "test_helper"

class SkinTest < MiniTest::Unit::TestCase
  def test_template_can_be_loaded
    skin = Slimmer::Skin.new "http://example.local/"
    expected_url = "http://example.local/templates/example.html.erb"
    stub_request(:get, expected_url).to_return :body => "<foo />"

    template = skin.load_template 'example'

    assert_requested :get, "http://example.local/templates/example.html.erb"
    assert_equal "<foo />", template
  end
end
