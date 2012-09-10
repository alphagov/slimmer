require_relative '../test_helper'

class RelatedItemsInserterTest < MiniTest::Unit::TestCase

  def setup
    super
    @related_template = File.read( File.dirname(__FILE__) + "/../fixtures/related.raw.html.erb" )
    @skin = stub("Skin", :template => @related_template)
    @artefact = {
      'slug' => 'vat',
      'title' => 'VAT',
      'related_items' => [
        { 'artefact' => { 'kind' => 'answer', 'name' => 'VAT rates', 'slug' => 'vat-rates' } },
        { 'artefact' => { 'kind' => 'guide', 'name' => 'Starting to import', 'slug' => 'starting-to-import' } },
      ]
    }
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
    assert_in template, "div.related h2", "Related topics"
    assert_in template, "div.related nav[role=navigation] ul li.answer:nth-child(1) a[href='/vat-rates']", "VAT rates"
    assert_in template, "div.related nav[role=navigation] ul li.guide:nth-child(2) a[href='/starting-to-import']", "Starting to import"
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
