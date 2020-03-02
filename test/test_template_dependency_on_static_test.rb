require "test_helper"

class TestTemplateDependencyOnStaticTest < MiniTest::Test
  def test_scripts_on_static_referenced_in_test_templates_exist
    template_path = File.dirname(__FILE__).gsub("/test", "/lib/slimmer/test_templates")
    Dir.foreach(template_path) do |template_file_name|
      next if [".", ".."].include? template_file_name

      doc = Nokogiri::HTML.fragment(File.read(File.join(template_path, template_file_name)))
      scripts = doc.search("script[src]").map { |node| node.attributes["src"].value }
      failing_scripts = allowing_real_web_connections do
        scripts.reject do |script_src|
          uri = URI.parse(script_src)
          http = Net::HTTP.new(uri.host, uri.port)
          if uri.scheme == "https"
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
          response = http.get(uri.request_uri)
          response.code == "200"
        end
      end
      assert failing_scripts.empty?, "Some scripts could not be loaded: #{failing_scripts.inspect}"
    end
  end
end
