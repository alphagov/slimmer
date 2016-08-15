require "test_helper"

class SearchPlaceholderSetterTest < MiniTest::Test
  def setup
    super
    @template = as_nokogiri %{
      <html>
      <head>
      </head>
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
    }
  end

  def test_should_rewrite_search_label
    Slimmer::Processors::SearchPlaceholderSetter.new(
      Slimmer::Headers::SEARCH_PLACEHOLDER_HEADER => "Search and destroy..."
    ).filter(nil, @template)
    assert_in @template, '#search label', 'Search and destroy...'
  end

  def test_should_rewrite_search_title
    Slimmer::Processors::SearchPlaceholderSetter.new(
      Slimmer::Headers::SEARCH_PLACEHOLDER_HEADER => "Search and destroy..."
    ).filter(nil, @template)
    assert_equal "Search and destroy...", @template.at_css("#site-search-text")['title']
  end

  def test_should_not_rewrite_search_label_with_no_header
    Slimmer::Processors::SearchPlaceholderSetter.new({}).filter(nil, @template)
    assert_in @template, '#search label', 'Search...'
  end

  def test_should_not_rewrite_search_title_with_no_header
    Slimmer::Processors::SearchPlaceholderSetter.new({}).filter(nil, @template)
    assert_equal "Search...", @template.at_css("#site-search-text")['title']
  end
end
