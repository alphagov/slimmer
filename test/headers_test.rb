require_relative "test_helper"
require "slimmer/headers"

class HeadersTest < MiniTest::Unit::TestCase
  include Slimmer::Headers
  attr_accessor :headers

  def setup
    self.headers = {}
  end

  def test_should_set_section_header
    set_slimmer_headers section: "rhubarb"
    assert_equal "rhubarb", headers["X-Slimmer-Section"]
  end

  def test_should_set_need_id_header
    set_slimmer_headers need_id: "rhubarb"
    assert_equal "rhubarb", headers["X-Slimmer-Need-ID"]
  end

  def test_should_set_format_header
    set_slimmer_headers format: "rhubarb"
    assert_equal "rhubarb", headers["X-Slimmer-Format"]
  end

  def test_should_set_proposition_header
    set_slimmer_headers proposition: "rhubarb"
    assert_equal "rhubarb", headers["X-Slimmer-Proposition"]
  end

  def test_should_set_result_count_header
    set_slimmer_headers result_count: 3
    assert_equal "3", headers["X-Slimmer-Result-Count"]
  end

  def test_should_set_template_header
    set_slimmer_headers template: "rhubarb"
    assert_equal "rhubarb", headers["X-Slimmer-Template"]
  end

  def test_should_set_skip_header
    set_slimmer_headers skip: "rhubarb"
    assert_equal "rhubarb", headers["X-Slimmer-Skip"]
  end

  def test_should_skip_missing_headers
    set_slimmer_headers section: "rhubarb"
    refute_includes headers.keys, "X-Slimmer-Need-ID"
  end

  def test_should_raise_an_exception_if_a_header_has_a_typo
    assert_raises Slimmer::Headers::InvalidHeader do
      set_slimmer_headers seccion: "wrong"
    end
  end
end

describe Slimmer::Headers do
  include Slimmer::Headers
  attr_accessor :headers

  before do
    self.headers = {}
  end

  describe "setting the artefact header" do
    it "should convert a hash to JSON and insert into the header" do
      artefact = {"foo" => "bar"}
      self.set_slimmer_artefact(artefact)
      assert_equal artefact.to_json, headers[Slimmer::Headers::ARTEFACT_HEADER]
    end

    it "should convert an OpenStruct to JSON" do
      artefact = OpenStruct.new("foo" => "bar")
      self.set_slimmer_artefact(artefact)
      assert_equal({"foo" => "bar"}.to_json, headers[Slimmer::Headers::ARTEFACT_HEADER])
    end

    it "should not have side-effects on the passed in hash" do
      artefact = {"foo" => "bar", "slug" => "vat-rates", "actions" => "some_actions"}
      artefact_copy = artefact.dup
      self.set_slimmer_artefact(artefact)
      assert_equal artefact_copy, artefact
    end
  end

  describe "setting a dummy artefact in the artefact header" do
    it "should setup an artefact title" do
      self.set_slimmer_dummy_artefact(:title => "Foo")

      artefact = JSON.parse(headers[Slimmer::Headers::ARTEFACT_HEADER])

      assert_equal "Foo", artefact["title"]
    end

    it "should setup a section tag for the given name and link" do
      self.set_slimmer_dummy_artefact(:section_name => "Foo", :section_link => "/something/foo")

      artefact = JSON.parse(headers[Slimmer::Headers::ARTEFACT_HEADER])

      assert_equal "Foo", artefact["tags"][0]["title"]
      assert_equal "section", artefact["tags"][0]["details"]["type"]
      assert_equal "/something/foo", artefact["tags"][0]["content_with_tag"]["web_url"]
    end
  end
end
