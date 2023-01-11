require "test_helper"

class NonceInserterTest < MiniTest::Test
  def test_decorates_an_inline_script_element
    request_env = Rack::MockRequest.env_for("https://new-example.com/new_path")
    request_env[ActionDispatch::ContentSecurityPolicy::Request::NONCE_GENERATOR] = ->(_) { "123456" }

    template = as_nokogiri("<html><script>document.write('hello')</script></html>")
    Slimmer::Processors::NonceInserter.new(request_env).filter(as_nokogiri(""), template)

    assert_equal %{<script nonce="123456">document.write('hello')</script>}, template.at_css("script").to_s
  end

  def test_doesnt_decorate_a_script_element_with_a_src
    request_env = Rack::MockRequest.env_for("https://new-example.com/new_path")
    request_env[ActionDispatch::ContentSecurityPolicy::Request::NONCE_GENERATOR] = ->(_) { "123456" }

    template = as_nokogiri(%(<html><script src="/script.js"></script></html>))
    Slimmer::Processors::NonceInserter.new(request_env).filter(as_nokogiri(""), template)

    assert_equal %(<script src="/script.js"></script>), template.at_css("script").to_s
  end

  def test_doesnt_decorate_an_inline_script_element_without_a_nonce_generator
    request_env = Rack::MockRequest.env_for("https://new-example.com/new_path")
    request_env[ActionDispatch::ContentSecurityPolicy::Request::NONCE_GENERATOR] = nil

    template = as_nokogiri("<html><script>document.write('hello')</script></html>")
    Slimmer::Processors::NonceInserter.new(request_env).filter(as_nokogiri(""), template)

    assert_equal "<script>document.write('hello')</script>", template.at_css("script").to_s
  end

  def test_doesnt_decorate_an_inline_script_element_when_rails_isnt_available
    # Utilise the Object.remove_const private method to temporarily unset a constant
    # This needs to be re-set at the end of the test otherwise it will impact
    # other tests.
    const_value = ActionDispatch.send(:remove_const, :Request)

    request_env = Rack::MockRequest.env_for("https://new-example.com/new_path")
    request_env[ActionDispatch::ContentSecurityPolicy::Request::NONCE_GENERATOR] = ->(_) { "123456" }

    template = as_nokogiri("<html><script>document.write('hello')</script></html>")
    Slimmer::Processors::NonceInserter.new(request_env).filter(as_nokogiri(""), template)

    assert_equal "<script>document.write('hello')</script>", template.at_css("script").to_s
    ActionDispatch.const_set(:Request, const_value)
  end
end
