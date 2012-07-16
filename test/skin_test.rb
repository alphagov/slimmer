require "test_helper"

class SkinTest < MiniTest::Unit::TestCase
  def test_template_can_be_loaded
    skin = Slimmer::Skin.new asset_host: "http://example.local/"
    expected_url = "http://example.local/templates/example.html.erb"
    stub_request(:get, expected_url).to_return :body => "<foo />"

    template = skin.template 'example'

    assert_requested :get, "http://example.local/templates/example.html.erb"
    assert_equal "<foo />", template
  end

  def test_templates_can_be_cached
    skin = Slimmer::Skin.new asset_host: "http://example.local/", use_cache: true
    expected_url = "http://example.local/templates/example.html.erb"
    stub_request(:get, expected_url).to_return :body => "<foo />"

    first_access = skin.template 'example'
    second_access = skin.template 'example'

    assert_requested :get, "http://example.local/templates/example.html.erb", times: 1
    assert_same first_access, second_access
  end

  def test_should_raise_appropriate_exception_when_template_not_found
    skin = Slimmer::Skin.new asset_host: "http://example.local/"
    expected_url = "http://example.local/templates/example.html.erb"
    stub_request(:get, expected_url).to_return(:status => '404')

    assert_raises(Slimmer::TemplateNotFoundException) do
      skin.template 'example'
    end
  end

  def test_should_raise_appropriate_exception_when_cant_reach_template_host
    skin = Slimmer::Skin.new asset_host: "http://example.local/"
    expected_url = "http://example.local/templates/example.html.erb"
    stub_request(:get, expected_url).to_raise(Errno::ECONNREFUSED)

    assert_raises(Slimmer::CouldNotRetrieveTemplate) do
      skin.template 'example'
    end
  end

  def test_should_raise_appropriate_exception_when_hostname_cannot_be_resolved
    skin = Slimmer::Skin.new asset_host: "http://non-existent.domain/"
    expected_url = "http://non-existent.domain/templates/example.html.erb"
    stub_request(:get, expected_url).to_raise(SocketError)

    assert_raises(Slimmer::CouldNotRetrieveTemplate) do
      skin.template 'example'
    end
  end
end
