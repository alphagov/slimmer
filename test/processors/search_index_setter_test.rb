require "test_helper"

module SearchIndexSetterTest

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
      "X-Slimmer-Search-Index" => "government",
    }

    given_response 200, DOCUMENT_WITH_SEARCH, headers

    def test_should_insert_index_field
      search_tab_field = Nokogiri::HTML.parse(last_response.body).at_css('input')['value']
      assert_equal "government-results", search_tab_field
    end
  end

  class WithoutHeaderTest < SlimmerIntegrationTest
    given_response 200, DOCUMENT_WITH_SEARCH, {}

    def test_should_not_insert_index_field
      search_tab_field = Nokogiri::HTML.parse(last_response.body).css('input')
      assert_equal 0, search_tab_field.length
    end
  end
end
