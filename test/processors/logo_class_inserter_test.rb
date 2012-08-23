require_relative "../test_helper.rb"

describe Slimmer::Processors::LogoClassInserter do

  before do
    @artefact = {
      "slug" => "vat",
      "tag_ids" => ['businesslink']
    }
    @processor = Slimmer::Processors::LogoClassInserter.new(@artefact)
    @template = as_nokogiri %{
      <html><body><div><div id="wrapper"></div></div></body></html>
    }
  end

  it "should add businesslink class to the wrapper" do
    @processor.filter(:any_source, @template)
    assert_in @template, "div#wrapper.businesslink"
  end

  it "should add multiple classes to the wrapper" do
    @artefact["tag_ids"] = ['businesslink', 'directgov']
    @processor.filter(:any_source, @template)
    assert_in @template, "div#wrapper.businesslink.directgov"
  end

  it "should ignore non-known tags" do
    @artefact["tag_ids"] = ['businesslink', 'business', 'fooey']
    @processor.filter(:any_source, @template)
    assert_in @template, "div#wrapper.businesslink"
    assert_not_in @template, "div#wrapper.business"
    assert_not_in @template, "div#wrapper.fooey"
  end

  it "should do nothing if the #wrapper element doesn't exist" do
    @template = as_nokogiri %{
      <html><body><div><div id="not_wrapper"></div></div></body></html>
    }
    @processor.filter(:any_source, @template)
    assert_in @template, "div#not_wrapper"
    assert_not_in @template, "div#wrapper"
  end

  it "should do nothing if the artefact has no tag_ids" do
    @artefact.delete("tag_ids")
    @processor.filter(:any_source, @template)
    assert_in @template, "div#wrapper"
  end
end
