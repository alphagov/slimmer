require "test_helper"

class SearchPlaceholderSetterIntegrationTest < SlimmerIntegrationTest
  TEMPLATE = <<-END
    <html>
      <head></head>
      <body class="body_class">
        <div id="wrapper">
          <form id="search" action="/path/to/search">
            <div class="content">
              <label for="site-search-text">Search...</label>
              <input type="search" name="q" id="site-search-text" title="Search...">
              <input class="submit" type="submit" value="Search">
            </div>
          </form>
        </div>
      </body>
    </html>
    END

  TEMPLATE_WITHOUT_SEARCH = <<-END
    <html>
      <head></head>
      <body class="body_class"></body>
    </html>
    END

  def test_should_not_modify_search_placeholder_if_no_header
    given_response 200, TEMPLATE, {}
    assert_equal '<label for="site-search-text">Search...</label>',
      Nokogiri::HTML.parse(last_response.body).at_css('#search label').to_s

    assert_equal '<input type="search" name="q" id="site-search-text" title="Search...">',
      Nokogiri::HTML.parse(last_response.body).at_css('#site-search-text').to_s
  end

  def test_should_modify_search_placeholder_to_value_of_header
    given_response 200, TEMPLATE,
      'X-Slimmer-Search-Placeholder' => 'Search and Destroy'
    assert_equal '<label for="site-search-text">Search and Destroy</label>',
      Nokogiri::HTML.parse(last_response.body).at_css('#search label').to_s

    assert_equal '<input type="search" name="q" id="site-search-text" title="Search and Destroy">',
      Nokogiri::HTML.parse(last_response.body).at_css('#site-search-text').to_s
  end

  def test_does_not_error_when_no_search_box_present
    given_response 200, TEMPLATE_WITHOUT_SEARCH,
      'X-Slimmer-Search-Placeholder' => 'Search and Destroy'
  end
end
