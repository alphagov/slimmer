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
          <div class='gem-c-layout-header'>
            <div class='govuk-header__navigation-container'>
              <ul>
                <li>
                  <a data-link-for='accounts-signed-out'></a>
                </li>
                <li>
                  <a data-link-for='accounts-signed-out'></a>
                </li>
                <li>
                  <a data-link-for='accounts-signed-in'></a>
                </li>
              </ul>
            </div>
          </div>
        </body>
      </html>
    )
  end

  def test_should_remove_accounts_and_layout_header_from_template_if_header_is_not_set
    headers = {}
    Slimmer::Processors::AccountsShower.new(
      headers,
    ).filter(nil, @template)

    assert_not_in @template, ".gem-c-layout-header"
    assert_not_in @template, "#global-header #accounts-signed-out"
    assert_not_in @template, "#global-header #accounts-signed-in"
    assert_in @template, "#accounts-signed-out"
    assert_in @template, "#accounts-signed-in"
  end

  def test_should_remove_global_header_and_signed_out_from_template_if_header_is_signed_in
    headers = { Slimmer::Headers::SHOW_ACCOUNTS_HEADER => "signed-in" }
    Slimmer::Processors::AccountsShower.new(
      headers,
    ).filter(nil, @template)

    assert_not_in @template, "#global-header"
    assert_not_in @template, ".gem-c-layout-header [data-link-for='accounts-signed-out']"
    assert_in @template, ".gem-c-layout-header [data-link-for='accounts-signed-in']"
    assert_in @template, "#accounts-signed-out"
    assert_in @template, "#accounts-signed-in"
  end

  def test_should_remove_global_header_and_signed_in_from_template_if_header_is_signed_out
    headers = { Slimmer::Headers::SHOW_ACCOUNTS_HEADER => "signed-out" }
    Slimmer::Processors::AccountsShower.new(
      headers,
    ).filter(nil, @template)

    assert_not_in @template, "#global-header"
    assert_not_in @template, ".gem-c-layout-header #account-manager"
    assert_not_in @template, ".gem-c-layout-header [data-link-for='accounts-signed-in']"
    assert_in @template, ".gem-c-layout-header [data-link-for='accounts-signed-out']"
    assert_in @template, "#accounts-signed-out"
    assert_in @template, "#accounts-signed-in"
  end
end
