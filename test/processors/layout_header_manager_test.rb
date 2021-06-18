require_relative "../test_helper"

class LayoutHeaderManagerTest < MiniTest::Test
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
          <header class='gem-c-layout-header'>
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
          </header>
        </body>
      </html>
    )

    @template_with_app_level_header_override = as_nokogiri %(
      <html>
        <head>
        </head>
        <body>
          <header id='global-header'>
            <div class='govuk-header__content'>
            </div>
          </header>
          <div id='wrapper'>
            <header class='gem-c-layout-header gem-c-layout-header--i-am-more-important'>
              <div class='govuk-header__content'>
              </div>
            </header>
          </div>
        </body>
      </html>
    )

    @gem_template = as_nokogiri %(
      <html>
        <head>
        </head>
        <body>
          <header class='gem-c-layout-header'>
            <div class='govuk-header__content'>
              <div class='govuk-header__navigation'>
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
          </header>
        </body>
      </html>
    )

    @gem_template_with_app_level_header_override = as_nokogiri %(
      <html>
        <head>
        </head>
        <body>
          <header class='gem-c-layout-header'>
            <div class='govuk-header__content'>
              <div class='govuk-header__navigation'>
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
          </header>
          <div id='wrapper'>
            <header class='gem-c-layout-header gem-c-layout-header--i-am-more-important'>
              <div class='govuk-header__content'>
                <div class='govuk-header__navigation'>
                  <ul>
                    <li>
                      <a data-link-for='app-level'></a>
                    </li>
                  </ul>
                </div>
              </div>
            </header>
          </div>
        </body>
      </html>
    )

    @gem_template_with_extra_navigation = as_nokogiri %(
      <html>
        <head>
        </head>
        <body>
          <header class='gem-c-layout-header'>
            <div class='govuk-header__content'>
              <div class='govuk-header__navigation'>
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
                  <li>
                    <a href='https://gov.uk/random'></a>
                  </li>
                </ul>
              </div>
            </div>
          </header>
        </body>
      </html>
    )
  end

  def test_should_remove_accounts_and_layout_header_from_template_if_header_is_not_set
    headers = {}
    Slimmer::Processors::LayoutHeaderManager.new(
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
    Slimmer::Processors::LayoutHeaderManager.new(
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
    Slimmer::Processors::LayoutHeaderManager.new(
      headers,
    ).filter(nil, @template)

    assert_not_in @template, "#global-header"
    assert_not_in @template, ".gem-c-layout-header #account-manager"
    assert_not_in @template, ".gem-c-layout-header [data-link-for='accounts-signed-in']"
    assert_in @template, ".gem-c-layout-header [data-link-for='accounts-signed-out']"
    assert_in @template, "#accounts-signed-out"
    assert_in @template, "#accounts-signed-in"
  end

  def test_should_remove_accounts_from_gem_template_if_header_is_not_set
    headers = {
      Slimmer::Headers::TEMPLATE_HEADER => "gem_layout",
    }

    Slimmer::Processors::LayoutHeaderManager.new(
      headers,
    ).filter(nil, @gem_template)

    assert_in @gem_template, ".gem-c-layout-header"
    assert_not_in @gem_template, ".gem-c-layout-header [data-link-for='accounts-signed-out']"
    assert_not_in @gem_template, ".gem-c-layout-header [data-link-for='accounts-signed-in']"
  end

  def test_should_remove_signed_out_from_gem_template_if_header_is_signed_in
    headers = {
      Slimmer::Headers::SHOW_ACCOUNTS_HEADER => "signed-in",
      Slimmer::Headers::TEMPLATE_HEADER => "gem_layout",
    }
    Slimmer::Processors::LayoutHeaderManager.new(
      headers,
    ).filter(nil, @gem_template)

    assert_in @gem_template, ".gem-c-layout-header"
    assert_in @gem_template, ".gem-c-layout-header [data-link-for='accounts-signed-in']"
    assert_not_in @gem_template, ".gem-c-layout-header [data-link-for='accounts-signed-out']"
  end

  def test_should_signed_in_from_gem_template_if_header_is_signed_out
    headers = {
      Slimmer::Headers::SHOW_ACCOUNTS_HEADER => "signed-out",
      Slimmer::Headers::TEMPLATE_HEADER => "gem_layout",
    }
    Slimmer::Processors::LayoutHeaderManager.new(
      headers,
    ).filter(nil, @gem_template)

    assert_in @gem_template, ".gem-c-layout-header"
    assert_not_in @gem_template, ".gem-c-layout-header [data-link-for='accounts-signed-in']"
    assert_in @gem_template, ".gem-c-layout-header [data-link-for='accounts-signed-out']"
  end

  def test_should_remove_navigation_if_navigation_empty
    headers = {
      Slimmer::Headers::TEMPLATE_HEADER => "gem_layout",
    }

    Slimmer::Processors::LayoutHeaderManager.new(
      headers,
    ).filter(nil, @gem_template)

    assert_in @gem_template, ".gem-c-layout-header"
    assert_not_in @gem_template, ".govuk-header__content"
  end

  def test_should_remove_accounts_from_gem_template_if_header_is_not_set_but_leave_other_navigation
    headers = {
      Slimmer::Headers::TEMPLATE_HEADER => "gem_layout",
    }

    Slimmer::Processors::LayoutHeaderManager.new(
      headers,
    ).filter(nil, @gem_template_with_extra_navigation)

    assert_in @gem_template_with_extra_navigation, ".gem-c-layout-header"
    assert_in @gem_template_with_extra_navigation, ".gem-c-layout-header a[href='https://gov.uk/random']"
    assert_not_in @gem_template_with_extra_navigation, ".gem-c-layout-header [data-link-for='accounts-signed-out']"
    assert_not_in @gem_template_with_extra_navigation, ".gem-c-layout-header [data-link-for='accounts-signed-in']"
  end

  def test_should_remove_signed_out_from_gem_template_if_header_is_signed_in_but_leave_other_navigation
    headers = {
      Slimmer::Headers::SHOW_ACCOUNTS_HEADER => "signed-in",
      Slimmer::Headers::TEMPLATE_HEADER => "gem_layout",
    }
    Slimmer::Processors::LayoutHeaderManager.new(
      headers,
    ).filter(nil, @gem_template_with_extra_navigation)

    assert_in @gem_template_with_extra_navigation, ".gem-c-layout-header"
    assert_in @gem_template_with_extra_navigation, ".gem-c-layout-header a[href='https://gov.uk/random']"
    assert_in @gem_template_with_extra_navigation, ".gem-c-layout-header [data-link-for='accounts-signed-in']"
    assert_not_in @gem_template_with_extra_navigation, ".gem-c-layout-header [data-link-for='accounts-signed-out']"
  end

  def test_should_signed_in_from_gem_template_if_header_is_signed_out_but_leave_other_navigation
    headers = {
      Slimmer::Headers::SHOW_ACCOUNTS_HEADER => "signed-out",
      Slimmer::Headers::TEMPLATE_HEADER => "gem_layout",
    }

    Slimmer::Processors::LayoutHeaderManager.new(
      headers,
    ).filter(nil, @gem_template_with_extra_navigation)

    assert_in @gem_template_with_extra_navigation, ".gem-c-layout-header"
    assert_in @gem_template_with_extra_navigation, ".gem-c-layout-header a[href='https://gov.uk/random']"
    assert_not_in @gem_template_with_extra_navigation, ".gem-c-layout-header [data-link-for='accounts-signed-in']"
    assert_in @gem_template_with_extra_navigation, ".gem-c-layout-header [data-link-for='accounts-signed-out']"
  end

  def test_should_replace_static_header_with_app_level_header_when_app_level_header_exists
    headers = {}
    Slimmer::Processors::LayoutHeaderManager.new(
      headers,
    ).filter(nil, @template_with_app_level_header_override)

    assert_not_in @template_with_app_level_header_override, "#wrapper .gem-c-layout-header"
    assert_not_in @template_with_app_level_header_override, "header#global-header"
    assert_in @template_with_app_level_header_override, ".gem-c-layout-header.gem-c-layout-header--i-am-more-important"
  end

  def test_should_replace_gem_header_with_app_level_header_when_app_level_header_exists
    headers = {
      Slimmer::Headers::TEMPLATE_HEADER => "gem_layout",
    }

    Slimmer::Processors::LayoutHeaderManager.new(
      headers,
    ).filter(nil, @gem_template_with_app_level_header_override)

    assert_in @gem_template_with_app_level_header_override, ".gem-c-layout-header--i-am-more-important"
    assert_in @gem_template_with_app_level_header_override, ".gem-c-layout-header a[data-link-for='app-level']"
    assert_not_in @gem_template_with_app_level_header_override, ".gem-c-layout-header [data-link-for='accounts-signed-out']"
    assert_not_in @gem_template_with_app_level_header_override, ".gem-c-layout-header [data-link-for='accounts-signed-in']"
    assert_not_in @gem_template_with_app_level_header_override, ".gem-c-layout-header:not(.gem-c-layout-header--i-am-more-important)"
  end
end
