require_relative "test_helper"
require "slimmer/headers"

class HeadersTest < MiniTest::Test
  include Slimmer::Headers
  attr_accessor :headers

  def setup
    self.headers = {}
  end

  def set_header(key, value)
    headers[key] = value
  end

  def test_should_set_section_header
    self.expects(:set_header).with("X-Slimmer-Section", "rhubarb")
    set_slimmer_headers section: "rhubarb"
  end

  def test_should_set_format_header
    self.expects(:set_header).with("X-Slimmer-Format", "rhubarb")
    set_slimmer_headers format: "rhubarb"
  end

  def test_should_set_application_name_header
    self.expects(:set_header).with("X-Slimmer-Application-Name", "whitehall")
    set_slimmer_headers application_name: "whitehall"
  end

  def test_should_set_page_owner_header
    self.expects(:set_header).with("X-Slimmer-Page-Owner", "bobby")
    set_slimmer_headers page_owner: "bobby"
  end

  def test_should_set_organisations_header
    self.expects(:set_header).with("X-Slimmer-Organisations", "<D123><P1>")
    set_slimmer_headers organisations: "<D123><P1>"
  end

  def test_should_set_result_count_header
    self.expects(:set_header).with("X-Slimmer-Result-Count", "3")
    set_slimmer_headers result_count: 3
  end

  def test_should_set_template_header
    self.expects(:set_header).with("X-Slimmer-Template", "rhubarb")
    set_slimmer_headers template: "rhubarb"
  end

  def test_should_set_skip_header
    self.expects(:set_header).with("X-Slimmer-Skip", "rhubarb")
    set_slimmer_headers skip: "rhubarb"
  end

  def test_should_raise_an_exception_if_a_header_has_a_typo
    assert_raises Slimmer::Headers::InvalidHeader do
      set_slimmer_headers seccion: "wrong"
    end
  end
end
