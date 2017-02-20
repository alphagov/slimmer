require "test_helper"

module SearchParameterInserterTest

  DOCUMENT_WITH_SEARCH = <<-END
    <html>
      <head>
      </head>
      <body class="body_class">
        <div id="wrapper">
          <form id="search" action="/path/to/search">
          </form>
        </div>
      </body>
    </html>
  END

  class WithHeaderTest < SlimmerIntegrationTest
    headers = {
      "X-Slimmer-Search-Parameters" => '{"filter_organisations": ["land-registry"], "count": 20}',
    }

    given_response 200, DOCUMENT_WITH_SEARCH, headers

    def test_should_add_hidden_input
      hidden_inputs = Nokogiri::HTML.parse(last_response.body).css('#search input[type=hidden]')
      assert_equal %{<input type="hidden" name="filter_organisations[]" value="land-registry"><input type="hidden" name="count" value="20">}, hidden_inputs.to_s
    end
  end

  class WithoutHeaderTest < SlimmerIntegrationTest
    given_response 200, DOCUMENT_WITH_SEARCH, {}

    def test_should_leave_original_search_action
      hidden_inputs = Nokogiri::HTML.parse(last_response.body).at_css('#search input[type=hidden]')
      assert_nil hidden_inputs
    end
  end
end
