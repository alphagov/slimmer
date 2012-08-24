require_relative "../test_helper"

class SectionInserterTest < MiniTest::Unit::TestCase

  # Note: the SectionInserter processor runs after the TagMover processor, so the meta
  # tags have already been moved into the destination template

  def test_should_add_section_link_to_breadcrumb
    template = as_nokogiri %{
      <html>
        <head>
          <meta content="Business" name="x-section-name">
          <meta content="/browse/business" name="x-section-link">
        </head>
        <body>
          <nav role="navigation">
            <ol><li><a href="/">Home</a></li></ol>
          </nav>
        </body>
      </html>
    }

    Slimmer::Processors::SectionInserter.new.filter(:any_source, template)
    assert_in template, "nav[role=navigation] ol li:nth-child(1)", %{<a href="/">Home</a>}
    assert_in template, "nav[role=navigation] ol li:nth-child(2)", %{<a href="/browse/business">Business</a>}
  end

  def test_should_add_section_link_after_last_item_in_breadcrumb
    template = as_nokogiri %{
      <html>
        <head>
          <meta content="Business" name="x-section-name">
          <meta content="/browse/business" name="x-section-link">
        </head>
        <body>
          <nav role="navigation">
            <ol>
              <li><a href="/">Home</a></li>
              <li><a href="/browse">All Sections</a></li>
            </ol>
          </nav>
        </body>
      </html>
    }

    Slimmer::Processors::SectionInserter.new.filter(:any_source, template)
    assert_in template, "nav[role=navigation] ol li:nth-child(1)", %{<a href="/">Home</a>}
    assert_in template, "nav[role=navigation] ol li:nth-child(2)", %{<a href="/browse">All Sections</a>}
    assert_in template, "nav[role=navigation] ol li:nth-child(3)", %{<a href="/browse/business">Business</a>}
  end

  def test_should_not_add_section_link_if_no_section_name_tag
    template = as_nokogiri %{
      <html>
        <head>
          <meta content="/browse/business" name="x-section-link">
        </head>
        <body>
          <nav role="navigation">
            <ol><li><a href="/">Home</a></li></ol>
          </nav>
        </body>
      </html>
    }

    Slimmer::Processors::SectionInserter.new.filter(:any_source, template)
    assert_in template, "nav[role=navigation] ol li:nth-child(1)", %{<a href="/">Home</a>}
    assert_not_in template, "nav[role=navigation] ol li:nth-child(2)"
  end

  def test_should_not_add_section_link_if_no_section_link_tag
    template = as_nokogiri %{
      <html>
        <head>
          <meta content="Business" name="x-section-name">
        </head>
        <body>
          <nav role="navigation">
            <ol><li><a href="/">Home</a></li></ol>
          </nav>
        </body>
      </html>
    }

    Slimmer::Processors::SectionInserter.new.filter(:any_source, template)
    assert_in template, "nav[role=navigation] ol li:nth-child(1)", %{<a href="/">Home</a>}
    assert_not_in template, "nav[role=navigation] ol li:nth-child(2)"
  end

  def test_should_do_nothing_if_navigation_not_in_template
    template = as_nokogiri %{
      <html>
        <head>
          <meta content="Business" name="x-section-name">
          <meta content="/browse/business" name="x-section-link">
        </head>
        <body>
        </body>
      </html>
    }

    Slimmer::Processors::SectionInserter.new.filter(:any_source, template)
    assert_not_in template, "nav[role=navigation]"
  end

  def test_should_not_blow_up_without_an_artefact
    template = as_nokogiri %{
      <html>
        <body>
          <nav role="navigation">
            <ol><li><a href="/">Home</a></li></ol>
          </nav>
        </body>
      </html>
    }

    # assert_nothing_raised do
    Slimmer::Processors::SectionInserter.new(nil).filter(:any_source, template)
  end
end
