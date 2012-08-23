require_relative "../test_helper"

class SectionInserterTest < MiniTest::Unit::TestCase

  # Note: the SectionInserter processor runs after the TagMover processor, so the meta
  # tags have already been moved into the destination template

  def test_should_add_section_link_to_breadcrumb
    artefact = {
      "slug" => "foo",
      "primary_section" => "business",
      "tags" => [
        {"id" => "business", "title" => "Business"},
      ]
    }
    template = as_nokogiri %{
      <html>
        <body>
          <nav role="navigation">
            <ol><li><a href="/">Home</a></li></ol>
          </nav>
        </body>
      </html>
    }

    Slimmer::Processors::SectionInserter.new(artefact).filter(:any_source, template)
    assert_in template, "nav[role=navigation] ol li:nth-child(1)", %{<a href="/">Home</a>}
    assert_in template, "nav[role=navigation] ol li:nth-child(2)", %{<a href="/browse/business">Business</a>}
  end

  def test_should_extract_base_section_from_primary_section
    artefact = {
      "slug" => "vat-rates",
      "primary_section" => "money-and-tax/tax",
      "tags" => [
        { "id" => "money-and-tax/tax", "title" => "Tax"},
        { "id" => "money-and-tax", "title" => "Money and tax"},
      ]
    }
    template = as_nokogiri %{
      <html>
        <body>
          <nav role="navigation">
            <ol><li><a href="/">Home</a></li></ol>
          </nav>
        </body>
      </html>
    }

    Slimmer::Processors::SectionInserter.new(artefact).filter(:any_source, template)
    assert_in template, "nav[role=navigation] ol li:nth-child(1)", %{<a href="/">Home</a>}
    assert_in template, "nav[role=navigation] ol li:nth-child(2)", %{<a href="/browse/money-and-tax">Money and tax</a>}
  end

  def test_should_add_section_link_after_last_item_in_breadcrumb
    artefact = {
      "slug" => "foo",
      "primary_section" => "business",
      "tags" => [
        {"id" => "business", "title" => "Business"},
      ]
    }
    template = as_nokogiri %{
      <html>
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

    Slimmer::Processors::SectionInserter.new(artefact).filter(:any_source, template)
    assert_in template, "nav[role=navigation] ol li:nth-child(1)", %{<a href="/">Home</a>}
    assert_in template, "nav[role=navigation] ol li:nth-child(2)", %{<a href="/browse">All Sections</a>}
    assert_in template, "nav[role=navigation] ol li:nth-child(3)", %{<a href="/browse/business">Business</a>}
  end

  def test_should_not_add_section_link_if_no_primary_section
    artefact = {
      "slug" => "foo",
      "tags" => [
        {"id" => "business", "title" => "Business"},
      ]
    }
    template = as_nokogiri %{
      <html>
        <body>
          <nav role="navigation">
            <ol><li><a href="/">Home</a></li></ol>
          </nav>
        </body>
      </html>
    }

    Slimmer::Processors::SectionInserter.new(artefact).filter(:any_source, template)
    assert_in template, "nav[role=navigation] ol li:nth-child(1)", %{<a href="/">Home</a>}
    assert_not_in template, "nav[role=navigation] ol li:nth-child(2)"
  end

  def test_should_not_add_section_link_if_no_corresponding_tag
    artefact = {
      "slug" => "foo",
      "primary_section" => "driving",
      "tags" => [
        {"id" => "business", "title" => "Business"},
      ]
    }
    template = as_nokogiri %{
      <html>
        <body>
          <nav role="navigation">
            <ol><li><a href="/">Home</a></li></ol>
          </nav>
        </body>
      </html>
    }

    Slimmer::Processors::SectionInserter.new(artefact).filter(:any_source, template)
    assert_in template, "nav[role=navigation] ol li:nth-child(1)", %{<a href="/">Home</a>}
    assert_not_in template, "nav[role=navigation] ol li:nth-child(2)"
  end

  def test_should_do_nothing_if_no_tags
    artefact = {
      "slug" => "foo",
      "primary_section" => "business",
    }
    template = as_nokogiri %{
      <html>
        <body>
          <nav role="navigation">
            <ol><li><a href="/">Home</a></li></ol>
          </nav>
        </body>
      </html>
    }

    Slimmer::Processors::SectionInserter.new(artefact).filter(:any_source, template)
    assert_in template, "nav[role=navigation] ol li:nth-child(1)", %{<a href="/">Home</a>}
    assert_not_in template, "nav[role=navigation] ol li:nth-child(2)"
  end

  def test_should_do_nothing_if_navigation_not_in_template
    artefact = {
      "slug" => "foo",
      "primary_section" => "business",
      "tags" => [
        {"id" => "business", "title" => "Business"},
      ]
    }
    template = as_nokogiri %{
      <html>
        <body>
        </body>
      </html>
    }

    Slimmer::Processors::SectionInserter.new(artefact).filter(:any_source, template)
    assert_not_in template, "nav[role=navigation]"
  end
end
