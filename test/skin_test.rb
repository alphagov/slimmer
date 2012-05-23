require "test_helper"

class SkinTest < MiniTest::Unit::TestCase
  def test_template_can_be_loaded
    skin = Slimmer::Skin.new asset_host: "http://example.local/"
    expected_url = "http://example.local/templates/example.html.erb"
    stub_request(:get, expected_url).to_return :body => "<foo />"

    template = skin.load_template 'example'

    assert_requested :get, "http://example.local/templates/example.html.erb"
    assert_equal "<foo />", template
  end

  def test_should_interpolate_values_for_prefix
    skin = Slimmer::Skin.new asset_host: "http://example.local/", use_cache: false, prefix: "this-is-the-prefix"
    expected_url = "http://example.local/templates/example.html.erb"
    stub_request(:get, expected_url).to_return :body => "<p><%= prefix %></p>"

    template = skin.load_template 'example'
    assert_equal "<p>this-is-the-prefix</p>", template
  end

  def test_should_raise_appropriate_exception_when_template_not_found
    skin = Slimmer::Skin.new asset_host: "http://example.local/"
    expected_url = "http://example.local/templates/example.html.erb"
    stub_request(:get, expected_url).to_return(:status => '404')

    assert_raises(Slimmer::TemplateNotFoundException) do
      skin.load_template 'example'
    end
  end

  def test_should_raise_appropriate_exception_when_cant_reach_template_host
    skin = Slimmer::Skin.new asset_host: "http://example.local/"
    expected_url = "http://example.local/templates/example.html.erb"
    stub_request(:get, expected_url).to_raise(Errno::ECONNREFUSED)

    assert_raises(Slimmer::CouldNotRetrieveTemplate) do
      skin.load_template 'example'
    end
  end
end
