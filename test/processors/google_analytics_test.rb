require_relative "../test_helper"
require "v8"

module GoogleAnalyticsTest
  PAGE_LEVEL_EVENT = 3

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

  module JavaScriptAssertions
    def gaq
      js = Nokogiri::HTML(last_response.body).at_css("#ga-params").text
      context = V8::Context.new
      context.eval(js)
      context.eval("_gaq");
    end

    def govuk
      js = Nokogiri::HTML(last_response.body).at_css("#ga-params").text
      context = V8::Context.new
      context.eval(js)
      context.eval("GOVUK.Analytics");
    end

    def assert_custom_var(slot, name, value, page_level)
      # Ruby Racer JS arrays don't accept range indexing, so we must
      # use a slightly longer workaround
      vars = gaq.select { |a| a[0] == "_setCustomVar" }.
                 map { |a| (1..4).map { |i| a[i] } }
      assert_includes vars, [slot, name, value, page_level]
    end

    def assert_set_var(name, value, object)
      assert_equal value, object.find { |each| each[0] == name }[1]
    end

    def refute_custom_var(name)
      vars = gaq.select { |a| a[0] == "_setCustomVar" }.map { |a| a[2] }
      refute_includes vars, name
    end
  end

  class WithHeadersTest < SlimmerIntegrationTest
    include JavaScriptAssertions

    def setup
      super

      artefact = artefact_for_slug_in_a_subsection("something", "rhubarb/in-puddings")
      artefact["details"].merge!(
        "need_id" => "42",
        "business_proposition" => true,
      )
      headers = {
        Slimmer::Headers::FORMAT_HEADER => "custard",
        Slimmer::Headers::RESULT_COUNT_HEADER => "3",
        Slimmer::Headers::ARTEFACT_HEADER => artefact.to_json,
        Slimmer::Headers::ORGANISATIONS_HEADER => "<P1><D422>"
      }

      given_response 200, GENERIC_DOCUMENT, headers
    end

    def test_should_pass_section_to_GA
      assert_custom_var 1, "Section", "rhubarb", PAGE_LEVEL_EVENT
    end

    def test_should_set_section_in_GOVUK_object
      assert_set_var "Section", "rhubarb", govuk
    end

    def test_should_pass_internal_format_name_to_GA
      assert_custom_var 2, "Format", "custard", PAGE_LEVEL_EVENT
    end

    def test_should_set_section_in_GOVUK_object
      assert_set_var "Format", "custard", govuk
    end

    def test_should_pass_need_ID_to_GA
      assert_custom_var 3, "NeedID", "42", PAGE_LEVEL_EVENT
    end

    def test_should_set_section_in_GOVUK_object
      assert_set_var "NeedID", "42", govuk
    end

    def test_should_pass_proposition_to_GA
      assert_custom_var 4, "Proposition", "business", PAGE_LEVEL_EVENT
    end

    def test_should_pass_organisation_to_GA
      assert_custom_var 9, "Organisations", "<P1><D422>", PAGE_LEVEL_EVENT
    end

    def test_should_set_section_in_GOVUK_object
      assert_set_var "Proposition", "trifle", govuk
    end

    def test_should_pass_result_count_to_GA
      assert_custom_var 5, "ResultCount", "3", PAGE_LEVEL_EVENT
    end

    def test_should_set_section_in_GOVUK_object
      assert_set_var "ResultCount", "3", govuk
    end
  end

  class WithoutHeadersTest < SlimmerIntegrationTest
    include JavaScriptAssertions

    given_response 200, GENERIC_DOCUMENT, {}

    def test_should_omit_section
      refute_custom_var "Section"
    end

    def test_should_omit_internal_format_name
      refute_custom_var "Format"
    end

    def test_should_omit_need_ID
      refute_custom_var "NeedID"
    end

    def test_should_omit_proposition
      refute_custom_var "Proposition"
    end

    def test_should_omit_organisations
      refute_custom_var "Organisations"
    end

    def test_should_omit_result_count
      refute_custom_var "ResultCount"
    end
  end

  class WithNilHeaderTest < SlimmerIntegrationTest
    include JavaScriptAssertions

    def setup
      super

      artefact = artefact_for_slug_in_a_subsection("something", "rhubarb/in-puddings")
      artefact["details"].merge!(
        "need_id" => "42",
        "business_proposition" => true
      )
      headers = {
        Slimmer::Headers::RESULT_COUNT_HEADER => "3",
        Slimmer::Headers::ARTEFACT_HEADER => artefact.to_json,
        Slimmer::Headers::ORGANISATIONS_HEADER => "<P1><D422>"
      }

      given_response 200, GENERIC_DOCUMENT, headers
    end

    def test_should_pass_organisation_to_GA_without_crashing
      assert_custom_var 9, "Organisations", "<P1><D422>", PAGE_LEVEL_EVENT
    end
  end
end
