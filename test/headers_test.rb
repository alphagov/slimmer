require_relative "test_helper"
require "slimmer/headers"

class HeadersTest < Minitest::Test
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

  def test_should_raise_an_exception_if_a_header_has_a_typo
    assert_raises Slimmer::Headers::InvalidHeader do
      set_slimmer_headers seccion: "wrong"
    end
  end
end
