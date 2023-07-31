require_relative "../test_helper"

class SearchRemoverTest < Minitest::Test
  def setup
    super
    @template = as_nokogiri %(
      <html>
        <head>
        </head>
        <body>
          <div id='global-header'>
            <button class='search-toggle'></button>
            <div id='search'></div>
          </div>
          <div id='search'></div>
        </body>
      </html>
    )

    @gem_template = as_nokogiri %(
      <html>
        <head>
        </head>
        <body>
          <div class="gem-c-layout-header__search">
          </div>
        </body>
      </html>
    )
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

    assert_not_in @template, "#global-header .search-toggle"
  end

  def test_should_not_remove_search_link_from_template_if_header_is_not_set
    headers = {}
    Slimmer::Processors::SearchRemover.new(
      headers,
    ).filter(nil, @template)

    assert_in @template, "#global-header .search-toggle"
  end

  def test_should_remove_search_from_gem_template_if_header_is_set
    headers = {
      Slimmer::Headers::REMOVE_SEARCH_HEADER => true,
    }
    Slimmer::Processors::SearchRemover.new(
      headers,
    ).filter(nil, @gem_template)

    assert_not_in @gem_template, ".gem-c-layout-header__search"
  end

  def test_should_not_remove_search_from_gem_template_if_header_is_not_set
    headers = {}
    Slimmer::Processors::SearchRemover.new(
      headers,
    ).filter(nil, @gem_template)

    assert_in @gem_template, ".gem-c-layout-header__search"
  end
end
