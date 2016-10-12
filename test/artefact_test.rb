require_relative "test_helper"
require 'gds_api/test_helpers/content_api'

describe Slimmer::Artefact do
  include GdsApi::TestHelpers::ContentApi

  it "should pull the slug out of the id" do
    a = Slimmer::Artefact.new(artefact_for_slug('vat-rates'))
    assert_equal 'vat-rates', a.slug
  end

  describe "Primary section" do
    before do
      @data = artefact_for_slug('something')
      @tag1 = tag_for_slug("fooey", "section")
      @tag2 = tag_for_slug("gooey", "section")
      @data["tags"] << @tag1 << @tag2
    end

    it "should return the first section tag" do
      assert_equal @tag1, Slimmer::Artefact.new(@data).primary_section
    end

    it "should ignore other tag types" do
      @data["tags"].unshift(tag_for_slug("other_tag", "another_tag"))
      assert_equal @tag1, Slimmer::Artefact.new(@data).primary_section
    end

    it "should return nil if there are no sections" do
      @data["tags"] = [tag_for_slug("other_tag", "another_tag")]
      assert_equal nil, Slimmer::Artefact.new(@data).primary_section
    end

    it "should return nil if there is no tags element" do
      @data.delete("tags")
      assert_equal nil, Slimmer::Artefact.new(@data).primary_section
    end
  end

  describe "Primary root section" do
    before do
      @artefact = Slimmer::Artefact.new(artefact_for_slug('something'))
      @tag1 = tag_for_slug("fooey", "section")
      @tag2 = tag_for_slug("gooey", "section")
      @tag3 = tag_for_slug("kablooie", "section")
    end

    it "should return the primary section if it has no parent" do
      @artefact.stubs(:primary_section).returns(@tag1)
      assert_equal @tag1, @artefact.primary_root_section
    end

    it "should return the primary section's parent" do
      @tag1["parent"] = @tag2
      @artefact.stubs(:primary_section).returns(@tag1)
      assert_equal @tag2, @artefact.primary_root_section
    end

    it "should support arbitrarily deep heirarchies" do
      @tag1["parent"] = @tag3
      @tag3["parent"] = @tag2
      @artefact.stubs(:primary_section).returns(@tag1)
      assert_equal @tag2, @artefact.primary_root_section
    end

    it "should return nil if there is no primary section" do
      @artefact.stubs(:primary_section).returns(nil)
      assert_equal nil, @artefact.primary_root_section
    end
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
      assert_equal "bar", @a.foo
    end

    it "should return nil if the field doesn't exist" do
      assert_equal nil, @a.non_existent
    end

    it "should not blow up if the details attribute doesn't exist" do
      @data.delete("details")
      assert_equal nil, @a.non_existent
    end
  end
end
