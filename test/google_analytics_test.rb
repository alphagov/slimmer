require "test_helper"
require "v8"

module GoogleAnalyticsTest

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

    def assert_custom_var(slot, name, value, page_level)
      # Ruby Racer JS arrays don't accept range indexing, so we must
      # use a slightly longer workaround
      vars = gaq.select { |a| a[0] == "_setCustomVar" }.
                 map { |a| (1..4).map { |i| a[i] } }
      assert_includes vars, [slot, name, value, page_level]
    end

    def refute_custom_var(name)
      vars = gaq.select { |a| a[0] == "_setCustomVar" }.map { |a| a[2] }
      refute_includes vars, name
    end
  end

  class WithHeadersTest < SlimmerIntegrationTest
    include JavaScriptAssertions
    PAGE_LEVEL_EVENT = 3

    headers = {
      "X-Slimmer-Section"       => "rhubarb",
      "X-Slimmer-Format"        => "custard",
      "X-Slimmer-Need-ID"       => "42",
      "X-Slimmer-Proposition"   => "trifle",
      "X-Slimmer-Result-Count"  => "3"
    }

    given_response 200, GENERIC_DOCUMENT, headers

    def test_should_pass_section_to_GA
      assert_custom_var 1, "Section", "rhubarb", PAGE_LEVEL_EVENT
    end

    def test_should_pass_internal_format_name_to_GA
      assert_custom_var 2, "Format", "custard", PAGE_LEVEL_EVENT
    end

    def test_should_pass_need_ID_to_GA
      assert_custom_var 3, "NeedID", "42", PAGE_LEVEL_EVENT
    end

    def test_should_pass_proposition_to_GA
      assert_custom_var 4, "Proposition", "trifle", PAGE_LEVEL_EVENT
    end

    def test_should_pass_result_count_to_GA
      assert_custom_var 5, "ResultCount", "3", PAGE_LEVEL_EVENT
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

    def test_should_omit_result_count
      refute_custom_var "ResultCount"
    end
  end
end
