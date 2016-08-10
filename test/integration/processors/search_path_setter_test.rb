require "test_helper"

module SearchPathSetterTest
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
      "X-Slimmer-Search-Path" => "/specialist/search",
    }

    given_response 200, DOCUMENT_WITH_SEARCH, headers

    def test_should_rewrite_search_action
      search_action = Nokogiri::HTML.parse(last_response.body).at_css('#search')["action"]
      assert_equal "/specialist/search", search_action
    end
  end

  class WithoutHeaderTest < SlimmerIntegrationTest
    given_response 200, DOCUMENT_WITH_SEARCH, {}

    def test_should_leave_original_search_action
      search_action = Nokogiri::HTML.parse(last_response.body).at_css('#search')["action"]
      assert_equal "/path/to/search", search_action
    end
  end
end
