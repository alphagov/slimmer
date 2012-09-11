require_relative "../test_helper.rb"
require 'gds_api/test_helpers/content_api'

describe Slimmer::Processors::LogoClassInserter do
  include GdsApi::TestHelpers::ContentApi

  def artefact_with_legacy_source_tags(legacy_sources)
    artefact = artefact_for_slug("vat")
    legacy_sources.each do |legacy_source|
      artefact["tags"] << basic_tag_for_slug(legacy_source, "legacy_source")
    end
    artefact
  end

  def business_link_artefact
    artefact_with_legacy_source_tags(["businesslink"])
  end

  def directgov_artefact
    artefact_with_legacy_source_tags(["directgov"])
  end

  def business_link_and_directgov_artefact
    artefact_with_legacy_source_tags(["directgov", "businesslink"])
  end

  def process(artefact, template)
    Slimmer::Processors::LogoClassInserter.new(artefact).filter(:any_source, template)
  end

  def example_template
    as_nokogiri %{
      <html><body><div><div id="wrapper"></div></div></body></html>
    }
  end

  it "should add businesslink class to the wrapper" do
    template = example_template
    process(business_link_artefact, template)
    assert_in template, "div#wrapper.businesslink"
  end

  it "should add multiple classes to the wrapper" do
    template = example_template
    artefact = business_link_and_directgov_artefact
    process(artefact, template)
    assert_in template, "div#wrapper.businesslink.directgov"
  end

  it "should ignore non-known tags" do
    template = example_template
    artefact = artefact_with_legacy_source_tags(["businesslink", "business", "fooey"])
    process(artefact, template)
    assert_in template, "div#wrapper.businesslink"
    assert_not_in template, "div#wrapper.business"
    assert_not_in template, "div#wrapper.fooey"
  end

  it "should do nothing if the #wrapper element doesn't exist" do
    artefact = directgov_artefact
    template = as_nokogiri %{
      <html><body><div><div id="not_wrapper"></div></div></body></html>
    }
    process(artefact, template)
    assert_in template, "div#not_wrapper"
    assert_not_in template, "div#wrapper"
  end

  it "should do nothing if the artefact has no tag_ids" do
    template = example_template
    artefact = artefact_for_slug("vat")
    process(artefact, template)
    assert_in template, "div#wrapper"
  end

  it "should not blow up without an artefact" do
    template = example_template
    processor = Slimmer::Processors::LogoClassInserter.new(nil)
    processor.filter(:any_source, template)
  end
end
