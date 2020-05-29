require "test_helper"

class HeaderContextInserterTest < MiniTest::Test
  def test_should_replace_contents_of_header_context_in_template
    template = as_nokogiri %(
      <html><body><div><div class="header-context"></div></div></body></html>
    )
    source = as_nokogiri %(
      <html><body><nav></nav><div class="header-context"><p>this should be moved</p></div></body></html>
    )

    Slimmer::Processors::HeaderContextInserter.new.filter(source, template)
    assert_in template, ".header-context", %(<p>this should be moved</p>)
  end

  def test_should_replace_classes_of_header_context_in_template
    template = as_nokogiri %(
      <html><body><div><div class="header-context template-class"></div></div></body></html>
    )
    source = as_nokogiri %(
      <html><body><nav></nav><div class="header-context app-class"><p>this should be moved</p></div></body></html>
    )

    Slimmer::Processors::HeaderContextInserter.new.filter(source, template)
    assert_in template, ".header-context.app-class", %(<p>this should be moved</p>)
    assert_not_in template, ".header-context.template-class"
  end

  def test_should_do_nothing_if_no_header_context_was_provided
    template = as_nokogiri %(
      <html><body><div><div class="header-context">should not be removed</div></div></body></html>
    )
    source = as_nokogiri %(
      <html><body><nav></nav></body></html>
    )

    Slimmer::Processors::HeaderContextInserter.new.filter(source, template)
    assert_in template, ".header-context", %(should not be removed)
  end

  def test_should_do_nothing_if_no_header_context_was_present_in_the_template
    template = as_nokogiri %(
      <html><body><div></div></body></html>
    )
    source = as_nokogiri %(
      <html><body><div><div class="header-context">should be ignored</div></div></body></html>
    )

    Slimmer::Processors::HeaderContextInserter.new.filter(source, template) # should not raise
  end
end
