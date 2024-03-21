require "test_helper"

class BodyInserterTest < Minitest::Test
  def test_should_raise_source_wrapper_div_not_found_error_when_wrapper_not_found
    template = as_nokogiri %(
      <html><body><div><div id="wrapper"></div></div></body></html>
    )
    source = as_nokogiri %(
      <html><body><nav></nav><div><p>this should be moved</p></div></body></html>
    )
    assert_raises(Slimmer::SourceWrapperNotFoundError) do
      Slimmer::Processors::BodyInserter.new.filter(source, template)
    end
  end

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
      <html><body>
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

  def test_should_merge_wrapper_css_classes_when_using_gem_layout
    template = as_nokogiri %(
      <html>
        <body>
          <div id="wrapper" class="template-css-class">Lorum ipsum.</div>
        </body>
      </html>
    )
    source = as_nokogiri %(
      <html>
        <body>
          <div id="wrapper" class="source-css-class"><p>Source content.</p></div>
        </body>
      </html>
    )

    headers = {
      Slimmer::Headers::TEMPLATE_HEADER => "gem_layout",
    }

    Slimmer::Processors::BodyInserter.new("wrapper", "wrapper", headers).filter(source, template)
    assert_in template, "#wrapper", "<p>Source content.</p>"
    assert_in template, ".source-css-class.template-css-class", "<p>Source content.</p>"
  end

  def test_should_merge_wrapper_css_classes_and_dedupe_when_using_gem_layout
    template = as_nokogiri %(
      <html>
        <body>
          <div id="wrapper" class="template-css-class another-class">Lorum ipsum.</div>
        </body>
      </html>
    )
    source = as_nokogiri %(
      <html>
        <body>
          <div id="wrapper" class="source-css-class another-class"><p>Source content.</p></div>
        </body>
      </html>
    )

    headers = {
      Slimmer::Headers::TEMPLATE_HEADER => "gem_layout",
    }

    Slimmer::Processors::BodyInserter.new("wrapper", "wrapper", headers).filter(source, template)
    assert_in template, "#wrapper", "<p>Source content.</p>"
    assert_in template, "[class='source-css-class another-class template-css-class']", "<p>Source content.</p>"
  end

  def test_should_merge_wrapper_css_classes_when_using_gem_layout_when_only_template_has_classes
    template = as_nokogiri %(
      <html>
        <body>
          <div id="wrapper" class="template-css-class">Lorum ipsum.</div>
        </body>
      </html>
    )
    source = as_nokogiri %(
      <html>
        <body>
          <div id="wrapper"><p>Source content.</p></div>
        </body>
      </html>
    )

    headers = {
      Slimmer::Headers::TEMPLATE_HEADER => "gem_layout",
    }

    Slimmer::Processors::BodyInserter.new("wrapper", "wrapper", headers).filter(source, template)
    assert_in template, "#wrapper", "<p>Source content.</p>"
    assert_in template, "[class='template-css-class']", "<p>Source content.</p>"
  end

  def test_should_merge_wrapper_css_classes_when_using_gem_layout_when_only_source_has_classes
    template = as_nokogiri %(
      <html>
        <body>
          <div id="wrapper">Lorum ipsum.</div>
        </body>
      </html>
    )
    source = as_nokogiri %(
      <html>
        <body>
          <div id="wrapper" class="source-css-class"><p>Source content.</p></div>
        </body>
      </html>
    )

    headers = {
      Slimmer::Headers::TEMPLATE_HEADER => "gem_layout",
    }

    Slimmer::Processors::BodyInserter.new("wrapper", "wrapper", headers).filter(source, template)
    assert_in template, "#wrapper", "<p>Source content.</p>"
    assert_in template, "[class='source-css-class']", "<p>Source content.</p>"
  end
end
