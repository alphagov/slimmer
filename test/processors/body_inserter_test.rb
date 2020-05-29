require "test_helper"

class BodyInserterTest < MiniTest::Test
  def test_should_replace_contents_of_wrapper_in_template
    template = as_nokogiri %(
      <html><body><div><div id="wrapper"></div></div></body></html>
    )
    source = as_nokogiri %(
      <html><body><nav></nav><div id="wrapper"><p>this should be moved</p></div></body></html>
    )

    Slimmer::Processors::BodyInserter.new.filter(source, template)
    assert_in template, "#wrapper", %(<p>this should be moved</p>)
  end

  def test_should_copy_across_unicode_characters_without_messing_with_their_encoding
    unicode_endash = [0x2013].pack("U*")
    template = as_nokogiri %(
      <html><body><div><div id="wrapper"></div></div></body></html>
    )
    source = as_nokogiri %(
      <html><body><nav></nav><div id="wrapper"><p>#{unicode_endash}</p></div></body></html>
    )

    Slimmer::Processors::BodyInserter.new.filter(source, template)
    assert_equal unicode_endash, template.at_css("#wrapper p").inner_text
  end

  def test_should_allow_replacement_of_arbitrary_segments_into_wrapper
    template = as_nokogiri %(
      <html><body><div>
      <div id="wrapper">don't touch this</div>
      </body></html>
    )
    source = as_nokogiri %(
      <html><body><div id="some_other_id"><p>this should be moved</p></div></body></html>
    )

    Slimmer::Processors::BodyInserter.new("some_other_id").filter(source, template)
    assert_not_in template, "#wrapper"
    assert_in template, "#some_other_id", %(<p>this should be moved</p>)
  end
end
