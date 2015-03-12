require_relative "../test_helper"

class SearchRemoverTest < MiniTest::Test
  def setup
    super
    @template = as_nokogiri %{
      <html>
        <head>
        </head>
        <body>
          <div id='global-header'>
            <a href='#search'></a>
            <div id='search'></div>
          </div>
          <div id='search'></div>
        </body>
      </html>
    }
  end

  def test_should_remove_search_from_template_if_header_is_set

    headers = { Slimmer::Headers::REMOVE_SEARCH_HEADER => true }
    Slimmer::Processors::SearchRemover.new(
      headers,
    ).filter(nil, @template)

    assert_not_in @template, "#global-header #search"
    assert_in @template, "#search"

  end

  def test_should_not_remove_search_from_template_if_header_is_not_set

    headers = {}
    Slimmer::Processors::SearchRemover.new(
      headers,
    ).filter(nil, @template)

    assert_in @template, "#global-header #search"
  end

  def test_should_remove_search_link_from_template_if_header_is_set

    headers = { Slimmer::Headers::REMOVE_SEARCH_HEADER => true }
    Slimmer::Processors::SearchRemover.new(
      headers,
    ).filter(nil, @template)

    assert_not_in @template, "#global-header a[href='#search']"
  end

  def test_should_not_remove_search_link_from_template_if_header_is_not_set

    headers = {}
    Slimmer::Processors::SearchRemover.new(
      headers,
    ).filter(nil, @template)

    assert_in @template, "#global-header a[href='#search']"
  end
end
