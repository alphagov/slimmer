require "test_helper"

module TypicalUsage
  class NormalResponseTest < MiniTest::Unit::TestCase
    include Rack::Test::Methods

    def app
      body = %{
        <html>
        <head><title>The title of the page</title>
        <meta name="something" content="yes">
        <meta name="x-section-name" content="This section">
        <meta name="x-section-link" content="/this_section">
        <script src="blah.js"></script>
        <link href="app.css" rel="stylesheet" type="text/css">
        </head>
        <body class="body_class">
        <div id="wrapper">The body of the page</div>
        </body>
        </html>
      }
      inner_app = proc { |env|
        [200, {"Content-Type" => "text/html"}, body]
      }
      Slimmer::App.new(inner_app)
    end

    def setup
      get "/"
    end

    def test_should_replace_the_wrapper_using_the_app_response
      assert_rendered_in_template "wrapper", "#wrapper", "The body of the page"
    end

    def test_should_replace_the_title_using_the_app_response
      assert_rendered_in_template "wrapper", "head title", "The title of the page"
    end

    def test_should_move_script_tags_into_the_head
      assert_rendered_in_template "wrapper", "head script[src='blah.js']"
    end

    def test_should_move_meta_tags_into_the_head
      assert_rendered_in_template "wrapper", "head meta[name='something']"
    end

    def test_should_move_stylesheet_tags_into_the_head
      assert_rendered_in_template "wrapper", "head link[href='app.css']"
    end

    def test_should_copy_the_class_of_the_body_element
      assert_rendered_in_template "wrapper", "body.body_class"
    end

    def test_should_insert_meta_navigation_links_into_the_navigation
      assert_rendered_in_template "wrapper", "nav[role=navigation] li a[href='/this_section']", "This section"
    end

    private

    def assert_rendered_in_template(template_name, selector, content=nil, message=nil)
      unless message
        if content
          message = "Expected to find #{content.inspect} at #{selector.inspect} in the output template"
        else
          message = "Expected to find #{selector.inspect} in the output template"
        end
      end
      element = Nokogiri::HTML.parse(last_response.body).at_css(selector)
      assert element, message
      assert_equal content, element.inner_html.to_s, message if content
    end
  end
end