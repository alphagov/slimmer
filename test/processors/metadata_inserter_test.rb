require_relative "../test_helper"

module MetadataInserterTest

  GENERIC_DOCUMENT = <<-END
    <html>
      <head>
        <title>The title of the page</title>
      </head>
      <body class="body_class">
        <div id="wrapper">The body of the page</div>
      </body>
    </html>
  END

  module MetaTagAssertions
    def assert_meta_tag(name, content)
      template = Nokogiri::HTML(last_response.body)
      assert_in template, "head meta[name='#{name}'][content='#{content}']"
    end

    def refute_meta_tag(name)
      template = Nokogiri::HTML(last_response.body)
      assert_not_in template, "head meta[name='#{name}']"
    end
  end

  class WithHeadersTest < SlimmerIntegrationTest
    include MetaTagAssertions

    def setup
      super

      artefact = artefact_for_slug_in_a_subsection("something", "rhubarb/in-puddings")
      artefact["details"].merge!(
        "need_ids" => [100001,100002],
      )
      headers = {
        Slimmer::Headers::FORMAT_HEADER => "custard",
        Slimmer::Headers::RESULT_COUNT_HEADER => "3",
        Slimmer::Headers::ARTEFACT_HEADER => artefact.to_json,
        Slimmer::Headers::ORGANISATIONS_HEADER => "<P1><D422>",
        Slimmer::Headers::WORLD_LOCATIONS_HEADER => "<WL3>"
      }

      given_response 200, GENERIC_DOCUMENT, headers
    end

    def test_should_include_section_meta_tag
      assert_meta_tag "section", "rhubarb"
    end

    def test_should_include_format_meta_tag
      assert_meta_tag "format", "custard"
    end

    def test_should_include_need_ids_meta_tag
      assert_meta_tag "need-ids", "100001,100002"
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

  class WithInvalidAttributes < SlimmerIntegrationTest
    include MetaTagAssertions

    def setup
      super
    end

    def test_should_skip_passing_need_ids_if_they_are_nil
      artefact = artefact_for_slug_in_a_subsection("something", "rhubarb/in-puddings")
      headers = {
        Slimmer::Headers::ARTEFACT_HEADER => artefact.to_json,
        Slimmer::Headers::FORMAT_HEADER => "custard"
      }
      given_response 200, GENERIC_DOCUMENT, headers

      refute_meta_tag "need-ids"
      # the presence of these attributes tests that the nil check worked
      assert_meta_tag "section", "rhubarb"
      assert_meta_tag "format", "custard"
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

    def test_should_omit_need_ID
      refute_meta_tag "need-ids"
    end

    def test_should_omit_organisations
      refute_meta_tag "organisations"
    end

    def test_should_omit_result_count
      refute_meta_tag "search-result-count"
    end
  end

  class WithNilHeaderTest < SlimmerIntegrationTest
    include MetaTagAssertions

    def setup
      super

      artefact = artefact_for_slug_in_a_subsection("something", "rhubarb/in-puddings")
      artefact["details"].merge!(
        "need_ids" => [100001, 100002],
      )
      headers = {
        Slimmer::Headers::RESULT_COUNT_HEADER => "3",
        Slimmer::Headers::ARTEFACT_HEADER => artefact.to_json,
        Slimmer::Headers::ORGANISATIONS_HEADER => "<P1><D422>"
      }

      given_response 200, GENERIC_DOCUMENT, headers
    end

    def test_should_include_organisation_meta_tag_without_crashing
      assert_meta_tag "organisations", "<P1><D422>"
    end
  end
end
