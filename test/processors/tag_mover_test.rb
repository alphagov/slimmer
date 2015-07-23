require_relative "../test_helper"

class TagMoverTest < MiniTest::Test
  def setup
    super
    @source = as_nokogiri %{
      <html>
        <head>
          <link rel="stylesheet" href="http://www.example.com/foo.css" />
          <link rel="hrefless_link" />
          <link rel="stylesheet" href="http://www.example.com/duplicate.css" />
          <meta name="foo" content="bar" />
          <meta name="no_content" />
          <meta content="no_name" />
          <meta name="duplicate" content="name and content" />
          <meta property="p:baz" content="bat" />
          <meta property="p:empty" />
        </head>
        <body class="mainstream">
          <div id="wrapper"></div>
          <script src="http://www.example.com/foo.js"></script>
          <script src="http://www.example.com/duplicate.js"></script>
        </body>
      </html>
    }
    @template = as_nokogiri %{
      <html>
        <head>
          <link rel="stylesheet" href="http://www.example.com/duplicate.css" />
          <meta name="duplicate" content="name and content" />
        </head>
        <body class="mainstream">
          <div id="wrapper"></div>
          <div id="related-items"></div>
          <script src="http://www.example.com/duplicate.js"></script>
          <script src="http://www.example.com/existing.js"></script>
        </body>
      </html>
    }
    Slimmer::Processors::TagMover.new.filter(@source, @template)
  end

  def test_should_move_script_tags_into_the_body
    assert_in @template, "script[src='http://www.example.com/foo.js']", nil, "Should have moved the script tag with src 'http://www.example.com/foo.js'"
  end

  def test_should_ignore_script_tags_already_in_the_destination_with_the_same_src_and_content
    assert @template.css("script[src='http://www.example.com/duplicate.js']").length == 1, "Expected there to only be one script tag with src 'http://www.example.com/duplicate.js'"
  end

  def test_should_place_source_script_tags_after_template_ones
    assert @template.to_s.index("foo.js") > @template.to_s.index("existing.js"), "Expected foo.js to be after existing.js"
  end


  def test_should_move_link_tags_into_the_head
    assert_in @template, "link[href='http://www.example.com/foo.css']", nil, "Should have moved the link tag with href 'http://www.example.com/foo.css'"
  end

  def test_should_ignore_link_tags_with_no_href
    assert_not_in @template, "link[rel='hrefless_link']"
  end

  def test_should_ignore_link_tags_already_in_the_destination_with_the_same_href
    assert @template.css("link[href='http://www.example.com/duplicate.css']").length == 1, "Expected there to only be one link tag with href 'http://www.example.com/duplicate.css'"
  end


  def test_should_move_meta_tags_into_the_head
    assert_in @template, "meta[name='foo'][content='bar']", nil, "Should have moved the foo=bar meta tag"
  end

  def test_should_ignore_meta_tags_with_no_name_or_content
    assert_not_in @template, "meta[name='no_content']"
    assert_not_in @template, "meta[content='no_name']"
  end

  def test_should_move_meta_tags_with_property_into_the_head
    assert_in @template, "meta[property='p:baz'][content='bat']", nil, "Should have moved the a:baz=bat meta (property) tag"
  end

  def test_should_ignore_meta_tags_with_property_but_no_content
    assert_not_in @template, "meta[property='p:empty']"
  end

  def test_should_ignore_meta_tags_already_in_the_destination_with_the_same_name_and_content
    assert @template.css("meta[name='duplicate'][content='name and content']").length == 1, "Expected there to only be one duplicate=name and content meta tag."
  end
end
