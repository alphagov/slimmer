require_relative "../test_helper"

class AccountsShowerTest < MiniTest::Test
  def setup
    super
    @template = as_nokogiri %(
      <html>
        <head>
        </head>
        <body>
          <div id='global-header'>
            <div id='accounts-signed-out'></div>
            <div id='accounts-signed-in'></div>
          </div>
          <div id='accounts-signed-out'></div>
          <div id='accounts-signed-in'></div>
        </body>
      </html>
    )
  end

  def test_should_remove_accounts_from_template_if_header_is_not_set
    headers = {}
    Slimmer::Processors::AccountsShower.new(
      headers,
    ).filter(nil, @template)

    assert_not_in @template, "#global-header #accounts-signed-out"
    assert_not_in @template, "#global-header #accounts-signed-in"
    assert_in @template, "#accounts-signed-out"
    assert_in @template, "#accounts-signed-in"
  end

  def test_should_remove_signed_out_from_template_if_header_is_signed_in
    headers = { Slimmer::Headers::SHOW_ACCOUNTS_HEADER => "signed-in" }
    Slimmer::Processors::AccountsShower.new(
      headers,
    ).filter(nil, @template)

    assert_not_in @template, "#global-header #accounts-signed-out"
    assert_in @template, "#global-header #accounts-signed-in"
    assert_in @template, "#accounts-signed-out"
    assert_in @template, "#accounts-signed-in"
  end

  def test_should_remove_signed_in_from_template_if_header_is_signed_out
    headers = { Slimmer::Headers::SHOW_ACCOUNTS_HEADER => "signed-out" }
    Slimmer::Processors::AccountsShower.new(
      headers,
    ).filter(nil, @template)

    assert_in @template, "#global-header #accounts-signed-out"
    assert_not_in @template, "#global-header #accounts-signed-in"
    assert_in @template, "#accounts-signed-out"
    assert_in @template, "#accounts-signed-in"
  end
end
