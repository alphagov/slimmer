require_relative "../test_helper"

class NavigationMoverTest < MiniTest::Test
  def setup
    super
    @proposition_header_block = File.read(File.dirname(__FILE__) + "/../fixtures/proposition_menu.html.erb")
    @skin = stub("Skin", template: @proposition_header_block)
  end

  def test_should_add_proposition_menu
    source = as_nokogiri %{
      <html>
        <body>
          <div id="proposition-menu"></div>
        </body>
      </html>
    }
    template = as_nokogiri %{
      <html>
        <body>
          <div id="global-header"><div class="header-wrapper"></div></div>
          <div id="wrapper"></div>
        </body>
      </html>
    }

    Slimmer::Processors::NavigationMover.new(@skin).filter(source, template)
    assert_in template, "div#global-header.with-proposition"
    assert_in template, "div#global-header #proposition-menu a", "Navigation item"
  end

  def test_should_not_add_proposition_menu_if_not_in_source
    source = as_nokogiri %{
      <html>
        <body>
          <div id="wrapper"></div>
        </body>
      </html>
    }
    template = as_nokogiri %{
      <html>
        <body>
          <div id="global_header"><div class="header-wrapper"></div></div>
          <div id="wrapper"></div>
        </body>
      </html>
    }

    @skin.expects(:template).never # Shouldn't fetch template when not inserting block
    Slimmer::Processors::NavigationMover.new(@skin).filter(source, template)
    assert_not_in template, "div#proposition_menu"
  end
end
