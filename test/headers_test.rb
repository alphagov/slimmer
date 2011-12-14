require "test_helper"
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
