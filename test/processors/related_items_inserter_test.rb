require_relative '../test_helper'
require 'gds_api/test_helpers/content_api'

class RelatedItemsInserterTest < MiniTest::Unit::TestCase
  include GdsApi::TestHelpers::ContentApi

  def setup
    super
    @related_template = File.read( File.dirname(__FILE__) + "/../fixtures/related.raw.html.erb" )
    @skin = stub("Skin", :template => @related_template)
    @artefact = Slimmer::Artefact.new artefact_for_slug_with_related_artefacts("vat", ["vat-rates", "starting-to-import"])
  end
  
  def test_should_add_related_items
    source = as_nokogiri %{
      <html>
        <body class="mainstream">
          <div id="wrapper">The body of the page<div id="related-items"></div></div>
        </body>
      </html>
    }
    template = as_nokogiri %{
      <html>
        <body class="mainstream">
          <div id="wrapper"></div>
          <div id="related-items"></div>
        </body>
      </html>
    }

    Slimmer::Processors::RelatedItemsInserter.new(@skin, @artefact).filter(source, template)
    assert_in template, "div.related h2", "More like this:"
    assert_in template, "div.related nav[role=navigation] ul li:nth-child(1) a[href='https://www.test.gov.uk/vat-rates']", "Vat rates"
    assert_in template, "div.related nav[role=navigation] ul li:nth-child(2) a[href='https://www.test.gov.uk/starting-to-import']", "Starting to import"
  end

  def test_should_not_add_related_items_for_non_mainstream_source
    source = as_nokogiri %{
      <html>
        <body class="nonmainstream">
          <div id="wrapper">The body of the page<div id="related-items"></div></div>
        </body>
      </html>
    }
    template = as_nokogiri %{
      <html>
        <body class="mainstream">
          <div id="wrapper"></div>
          <div id="related-items"></div>
        </body>
      </html>
    }

    @skin.expects(:template).never # Shouldn't fetch template when not inserting block

    Slimmer::Processors::RelatedItemsInserter.new(@skin, @artefact).filter(source, template)
    assert_not_in template, "div.related"
  end
end
