require_relative "../test_helper"
require 'gds_api/test_helpers/content_api'

class SectionInserterTest < MiniTest::Unit::TestCase
  include GdsApi::TestHelpers::ContentApi

  def create_artefact(slug, attributes = {})
    if section_slug = attributes.delete("section_slug")
      if subsection_slug = attributes.delete("subsection_slug")
        a = artefact_for_slug_in_a_subsection(slug, "#{section_slug}/#{subsection_slug}")
      else
        a = artefact_for_slug_in_a_section(slug, section_slug)
      end
    else
      a = artefact_for_slug(slug)
    end
    Slimmer::Artefact.new(a.merge(attributes))
  end

  def test_should_add_section_link_and_title_to_breadcrumb
    artefact = create_artefact("something",
                               "section_slug" => "business")

    template = as_nokogiri %{
      <html>
        <body>
          <div class="header-context">
            <nav role="navigation">
              <ol class="group">
                <li><a href="/">Home</a></li>
              </ol>
            </nav>
          </div>
        </body>
      </html>
    }

    Slimmer::Processors::SectionInserter.new(artefact).filter(:any_source, template)
    list = template.at_css(".header-context nav[role=navigation] ol")
    assert_in list, "li:nth-child(1)", %{<a href="/">Home</a>}
    assert_in list, "li:nth-child(2)", %{<strong><a href="https://www.test.gov.uk/browse/business">Business</a></strong>}
  end

  def test_should_add_section_link_subsection_link_and_title_to_breadcrumb
    artefact = create_artefact("something",
                               "section_slug" => "business",
                               "subsection_slug" => "employing-people")

    template = as_nokogiri %{
      <html>
        <body>
          <div class="header-context">
            <nav role="navigation">
              <ol class="group"><li><a href="/">Home</a></li></ol>
            </nav>
          </div>
        </body>
      </html>
    }

    Slimmer::Processors::SectionInserter.new(artefact).filter(:any_source, template)
    list = template.at_css(".header-context nav[role=navigation] ol")
    assert_in list, "li:nth-child(1)", %{<a href="/">Home</a>}
    assert_in list, "li:nth-child(2)", %{<a href="https://www.test.gov.uk/browse/business">Business</a>}
    assert_in list, "li:nth-child(3)", %{<strong><a href="https://www.test.gov.uk/browse/business/employing-people">Employing people</a></strong>}
  end

  def test_should_add_links_after_last_item_in_breadcrumb
    artefact = create_artefact("something",
                               "section_slug" => "business",
                               "subsection_slug" => "employing-people")

    template = as_nokogiri %{
      <html>
        <body>
          <div class="header-context">
            <nav role="navigation">
              <ol class="group">
                <li><a href="/">Home</a></li>
                <li><a href="/browse">All Sections</a></li>
              </ol>
            </nav>
          </div>
        </body>
      </html>
    }

    Slimmer::Processors::SectionInserter.new(artefact).filter(:any_source, template)
    list = template.at_css(".header-context nav[role=navigation] ol")
    assert_in list, "li:nth-child(1)", %{<a href="/">Home</a>}
    assert_in list, "li:nth-child(2)", %{<a href="/browse">All Sections</a>}
    assert_in list, "li:nth-child(3)", %{<a href="https://www.test.gov.uk/browse/business">Business</a>}
    assert_in list, "li:nth-child(4)", %{<strong><a href="https://www.test.gov.uk/browse/business/employing-people">Employing people</a></strong>}
  end

  def test_should_do_nothing_if_navigation_not_in_template
    artefact = create_artefact("something")
    template = as_nokogiri %{
      <html>
        <body>
        </body>
      </html>
    }

    Slimmer::Processors::SectionInserter.new(artefact).filter(:any_source, template)
    assert_not_in template, "nav[role=navigation]"
  end

  def test_should_do_nothing_with_no_artefact
    template = as_nokogiri %{
      <html>
        <body>
          <div class="header-context">
            <nav role="navigation">
              <ol class="group"><li><a href="/">Home</a></li></ol>
            </nav>
          </div>
        </body>
      </html>
    }

    Slimmer::Processors::SectionInserter.new(nil).filter(:any_source, template)
    list = template.at_css(".header-context nav[role=navigation] ol")
    assert_in list, "li:nth-child(1)", %{<a href="/">Home</a>}
    assert_not_in list, "li:nth-child(2)"
  end

  def test_should_not_fail_with_no_sections
    artefact = create_artefact("something")

    template = as_nokogiri %{
      <html>
        <body>
          <div class="header-context">
            <nav role="navigation">
              <ol class="group">
                <li><a href="/">Home</a></li>
              </ol>
            </nav>
          </div>
        </body>
      </html>
    }

    Slimmer::Processors::SectionInserter.new(artefact).filter(:any_source, template)
    list = template.at_css(".header-context nav[role=navigation] ol")
    assert_in list, "li:nth-child(1)", %{<a href="/">Home</a>}
  end

  def test_should_support_multiple_levels_of_navigation
    artefact = create_artefact("something",
                               "section_slug" => "business",
                               "subsection_slug" => "employing-people/deep-section")

    template = as_nokogiri %{
      <html>
        <body>
          <div class="header-context">
            <nav role="navigation">
              <ol class="group">
                <li><a href="/">Home</a></li>
                <li><a href="/browse">All Sections</a></li>
              </ol>
            </nav>
          </div>
        </body>
      </html>
    }

    Slimmer::Processors::SectionInserter.new(artefact).filter(:any_source, template)
    list = template.at_css(".header-context nav[role=navigation] ol")
    assert_in list, "li:nth-child(1)", %{<a href="/">Home</a>}
    assert_in list, "li:nth-child(2)", %{<a href="/browse">All Sections</a>}
    assert_in list, "li:nth-child(3)", %{<a href="https://www.test.gov.uk/browse/business">Business</a>}
    assert_in list, "li:nth-child(4)", %{<a href="https://www.test.gov.uk/browse/business/employing-people">Employing people</a>}
    assert_in list, "li:nth-child(5)", %{<strong><a href="https://www.test.gov.uk/browse/business/employing-people/deep-section">Deep section</a></strong>}
  end

end
