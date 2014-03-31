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

  def test_should_set_format_header
    set_slimmer_headers format: "rhubarb"
    assert_equal "rhubarb", headers["X-Slimmer-Format"]
  end

  def test_should_set_application_name_header
    set_slimmer_headers application_name: "whitehall"
    assert_equal "whitehall", headers["X-Slimmer-Application-Name"]
  end

  def test_should_set_page_owner_header
    set_slimmer_headers page_owner: "bobby"
    assert_equal "bobby", headers["X-Slimmer-Page-Owner"]
  end

  def test_should_set_organisations_header
    set_slimmer_headers organisations: "<D123><P1>"
    assert_equal "<D123><P1>", headers["X-Slimmer-Organisations"]
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

  def test_should_not_have_meta_viewport_header_set
    assert_equal nil, headers["X-Slimmer-Remove-Meta-Viewport"]
  end

  def test_should_set_meta_viewport_header
    set_slimmer_headers remove_meta_viewport: true
    assert_equal "true", headers["X-Slimmer-Remove-Meta-Viewport"]
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

    it "should handle an object that responds to :to_hash" do
      hash = {"foo" => "bar", "slug" => "vat-rates"}
      artefact = stub("Response", :to_hash => hash)
      self.set_slimmer_artefact(artefact)
      assert_equal hash.to_json, headers[Slimmer::Headers::ARTEFACT_HEADER]
    end

    it "should not have side-effects on the passed in hash" do
      artefact = {"foo" => "bar", "slug" => "vat-rates", "actions" => "some_actions"}
      artefact_copy = artefact.dup
      self.set_slimmer_artefact(artefact)
      assert_equal artefact_copy, artefact
    end
  end

  describe "setting the artefact and adding a dummy section" do
    it "should setup a section tag for the given name and link" do
      artefact_input = {"foo" => "bar", "slug" => "vat-rates", "actions" => "some_actions"}
      self.set_slimmer_artefact_overriding_section(artefact_input, :section_name => "Foo", :section_link => "/something/foo")

      artefact = JSON.parse(headers[Slimmer::Headers::ARTEFACT_HEADER])

      assert_equal "Foo", artefact["tags"][0]["title"]
      assert_equal "section", artefact["tags"][0]["details"]["type"]
      assert_equal "/something/foo", artefact["tags"][0]["content_with_tag"]["web_url"]
    end

    it "should not overwrite existing tags" do
      artefact_input = {"foo" => "bar", "slug" => "vat-rates", "actions" => "some_actions", "tags" => ["foo", "bar"]}
      self.set_slimmer_artefact_overriding_section(artefact_input, :section_name => "Foo", :section_link => "/something/foo")

      artefact = JSON.parse(headers[Slimmer::Headers::ARTEFACT_HEADER])

      assert_equal ["foo", "bar"], artefact["tags"][1..-1]
    end

    it "should not have side-effects on the passed in hash" do
      artefact_input = {"foo" => "bar", "slug" => "vat-rates", "actions" => "some_actions"}
      artefact_copy = artefact_input.dup
      self.set_slimmer_artefact_overriding_section(artefact_input, :section_name => "Foo", :section_link => "/foo")
      assert_equal artefact_copy, artefact_input
    end

    it "should work correctly with a gds_api response object" do
      input_artefact = {"foo" => "bar", "slug" => "vat-rates", "actions" => "some_actions"}
      api_response = GdsApi::Response.new(stub("HTTP Response", :code => 200, :body => input_artefact.to_json))
      self.set_slimmer_artefact_overriding_section(api_response, :section_name => "Foo", :section_link => "/something/foo")

      artefact = JSON.parse(headers[Slimmer::Headers::ARTEFACT_HEADER])

      assert_equal "Foo", artefact["tags"][0]["title"]
      assert_equal "section", artefact["tags"][0]["details"]["type"]
      assert_equal "/something/foo", artefact["tags"][0]["content_with_tag"]["web_url"]
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

    it "can set up a section tag with multiple levels of parents" do
      self.set_slimmer_dummy_artefact(
        :section_name => "Foo",
        :section_link => "/something/baz/bar/foo",
        :parent => {
          :section_name => "Bar",
          :section_link => "/something/baz/bar",
          :parent => {
            :section_name => "Baz",
            :section_link => "/something/baz"
          }
        }
      )

      artefact = JSON.parse(headers[Slimmer::Headers::ARTEFACT_HEADER])

      assert_equal "Foo", artefact["tags"][0]["title"]
      assert_equal "section", artefact["tags"][0]["details"]["type"]
      assert_equal "/something/baz/bar/foo", artefact["tags"][0]["content_with_tag"]["web_url"]

      assert_equal "Bar", artefact["tags"][0]["parent"]["title"]
      assert_equal "section", artefact["tags"][0]["parent"]["details"]["type"]
      assert_equal "/something/baz/bar", artefact["tags"][0]["parent"]["content_with_tag"]["web_url"]

      assert_equal "Baz", artefact["tags"][0]["parent"]["parent"]["title"]
      assert_equal "section", artefact["tags"][0]["parent"]["parent"]["details"]["type"]
      assert_equal "/something/baz", artefact["tags"][0]["parent"]["parent"]["content_with_tag"]["web_url"]

    end
  end
end
