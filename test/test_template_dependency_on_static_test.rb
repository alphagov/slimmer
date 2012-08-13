require "test_helper"
require "slimmer/test_template"

class TestTemplateDependencyOnStaticTest < MiniTest::Unit::TestCase
  def test_test_template_static_asset_urls_should_be_valid
    doc = Nokogiri::HTML.fragment(Slimmer::TestTemplate::TEMPLATE)
    scripts = doc.search("script").map { |node| node.attributes["src"].value }
    failing_scripts = allowing_real_web_connections do
      scripts.select do |script_src|
        Net::HTTP.get_response(URI.parse(script_src)).code != "200"
      end
    end
    assert failing_scripts.empty?, "Some scripts could not be loaded: #{failing_scripts.inspect}"
  end
end
