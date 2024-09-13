require_relative "../test_helper"

module MetadataInserterTest
  GENERIC_DOCUMENT = <<-HTML.freeze
    <html>
      <head>
        <title>The title of the page</title>
      </head>
      <body class="body_class">
        <div id="wrapper">The body of the page</div>
      </body>
    </html>
  HTML

  module MetaTagAssertions
    def assert_meta_tag(name, content)
      template = Nokogiri::HTML(last_response.body)
      assert_in template, "head meta[name='govuk:#{name}'][content='#{content}']"
    end

    def refute_meta_tag(name)
      template = Nokogiri::HTML(last_response.body)
      assert_not_in template, "head meta[name='govuk:#{name}']"
    end
  end

  class WithHeadersTest < SlimmerIntegrationTest
    include MetaTagAssertions

    def setup
      super

      headers = {
        Slimmer::Headers::FORMAT_HEADER => "custard",
        Slimmer::Headers::RESULT_COUNT_HEADER => "3",
        Slimmer::Headers::ORGANISATIONS_HEADER => "<P1><D422>",
        Slimmer::Headers::WORLD_LOCATIONS_HEADER => "<WL3>",
      }

      given_response 200, GENERIC_DOCUMENT, headers
    end

    def test_should_include_format_meta_tag
      assert_meta_tag "format", "custard"
    end

    def test_should_include_organisations_meta_tag
      assert_meta_tag "organisations", "<P1><D422>"
    end

    def test_should_include_world_locations_meta_tag
      assert_meta_tag "world-locations", "<WL3>"
    end

    def test_should_include_search_result_count_meta_tag
      assert_meta_tag "search-result-count", "3"
    end
  end

  class WithoutHeadersTest < SlimmerIntegrationTest
    include MetaTagAssertions

    given_response 200, GENERIC_DOCUMENT, {}

    def test_should_omit_section
      refute_meta_tag "section"
    end

    def test_should_omit_internal_format_name
      refute_meta_tag "format"
    end

    def test_should_omit_organisations
      refute_meta_tag "organisations"
    end

    def test_should_omit_world_locations
      refute_meta_tag "world-locations"
    end

    def test_should_omit_result_count
      refute_meta_tag "search-result-count"
    end
  end
end
