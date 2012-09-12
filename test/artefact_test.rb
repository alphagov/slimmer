require_relative "test_helper"
require 'gds_api/test_helpers/content_api'

describe Slimmer::Artefact do
  include GdsApi::TestHelpers::ContentApi

  it "should pull the slug out of the id" do
    a = Slimmer::Artefact.new(artefact_for_slug('vat-rates'))
    assert_equal 'vat-rates', a.slug
  end

  describe "Related artefacts" do
    before do
      @data = artefact_for_slug('something')
    end
    
    it "should return an array of corresponding artefact instances" do
      @data["related"] << artefact_for_slug('vat')
      @data["related"] << artefact_for_slug('something-else')
      a = Slimmer::Artefact.new(@data)
      related = a.related_artefacts
      assert_equal [Slimmer::Artefact, Slimmer::Artefact], related.map(&:class)
      assert_equal %w(vat something-else), related.map(&:slug)
    end

    it "should return empty array if there is no 'related' element" do
      @data.delete("related")
      assert_equal [], Slimmer::Artefact.new(@data).related_artefacts
    end
  end

  describe "Legacy sources" do
    before do
      @data = artefact_for_slug('something')
    end

    it "should return the slugs of all legacy_source tags" do
      @data["tags"] << tag_for_slug('businesslink', 'legacy_source')
      @data["tags"] << tag_for_slug('directgov', 'legacy_source')
      assert_equal ['businesslink', 'directgov'], Slimmer::Artefact.new(@data).legacy_sources.sort
    end

    it "should not include other tags" do
      @data["tags"] << tag_for_slug('businesslink', 'legacy_source')
      @data["tags"] << tag_for_slug('business', 'proposition')
      @data["tags"] << tag_for_slug('directgov', 'legacy_source')
      assert_equal ['businesslink', 'directgov'], Slimmer::Artefact.new(@data).legacy_sources.sort
    end

    it "should return empty array if the data hs no tags element" do
      @data.delete("tags")
      assert_equal [], Slimmer::Artefact.new(@data).legacy_sources
    end
  end

  describe "method_missing accessing artefact fields" do
    before do
      @data = artefact_for_slug('something')
      @data["foo"] = "bar"
      @a = Slimmer::Artefact.new(@data)
    end

    it "should return corresponding field" do
      assert_equal @data["title"], @a.title
      assert_equal "bar", @a.foo
    end

    it "should return the corresponding field from details if it doesn't exist at the top level" do
      @data["details"]["foo"] = "baz"
      assert_equal @data["details"]["need_id"], @a.need_id
      assert_equal "bar", @a.foo
    end

    it "should return nil if the field doesn't exist" do
      assert_equal nil, @a.non_existent
    end
  end
end
