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
      search_index = Nokogiri::HTML.parse(last_response.body).at_css('#search input[name=search-index]')['value']
      assert_equal "government", search_index
    end
  end

  class WithoutHeaderTest < SlimmerIntegrationTest
    given_response 200, DOCUMENT_WITH_SEARCH, {}

    def test_should_not_insert_index_field
      search_index = Nokogiri::HTML.parse(last_response.body).at_css('#search input[name=search-index]')
      assert_equal nil, search_index
    end
  end
end
