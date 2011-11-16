require "test_helper"

class BodyInserterTest < MiniTest::Unit::TestCase
  def test_should_replace_contents_of_wrapper_in_template
    template = as_nokogiri %{
      <html><body><div><div id="wrapper"></div></div></body></html>
    }
    expected = %{
      <div id="wrapper"><p>this should be moved</p></div>
    }.strip
    source = as_nokogiri %{
      <html><body><nav></nav><div id="wrapper"><p>this should be moved</p></div></body></html>
    }
    assert_equal expected, Slimmer::BodyInserter.new.filter(source, template).to_s
  end

  def test_should_allow_replacement_of_arbitrary_wrappers
    template = as_nokogiri %{
      <html><body><div><div id="some_other_id"></div></div></body></html>
    }
    expected = %{
      <div id="some_other_id"><p>this should be moved</p></div>
    }.strip
    source = as_nokogiri %{
      <html><body><div id="wrapper">don't touch this</div>
        <div id="some_other_id"><p>this should be moved</p></div></body></html>
    }
    assert_equal expected, Slimmer::BodyInserter.new("#some_other_id").filter(source, template).to_s
  end
end