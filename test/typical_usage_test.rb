require "test_helper"

module TypicalUsage
  class NormalResponseTest < SlimmerIntegrationTest

    given_response 200, %{
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

    def test_should_replace_the_wrapper_using_the_app_response
      assert_rendered_in_template "#wrapper", "The body of the page"
    end

    def test_should_replace_the_title_using_the_app_response
      assert_rendered_in_template "head title", "The title of the page"
    end

    def test_should_move_script_tags_into_the_head
      assert_rendered_in_template "head script[src='blah.js']"
    end

    def test_should_move_meta_tags_into_the_head
      assert_rendered_in_template "head meta[name='something']"
    end

    def test_should_move_stylesheet_tags_into_the_head
      assert_rendered_in_template "head link[href='app.css']"
    end

    def test_should_copy_the_class_of_the_body_element
      assert_rendered_in_template "body.body_class"
    end

    def test_should_insert_meta_navigation_links_into_the_navigation
      assert_rendered_in_template "nav[role=navigation] li a[href='/this_section']", "This section"
    end
  end

  class Error500ResponseTest < SlimmerIntegrationTest
    include Rack::Test::Methods

    given_response 500, %{
      <html>
      <head><title>500 Error</title>
      <meta name="something" content="yes">
      <meta name="x-section-name" content="This section">
      <meta name="x-section-link" content="/this_section">
      <script src="blah.js"></script>
      <link href="app.css" rel="stylesheet" type="text/css">
      </head>
      <body class="body_class">
      <div id="wrapper"><p class='message'>Something bad happened</p></div>
      </body>
      </html>
    }

    def test_should_not_replace_the_wrapper_using_the_app_response
      assert_not_rendered_in_template "Something bad happened"
    end

    def test_should_include_default_500_error_message
      assert_rendered_in_template "body .content header h1", "We seem to be having a problem."
    end

    def test_should_replace_the_title_using_the_app_response
      assert_rendered_in_template "head title", "500 Error"
    end
  end

  class Error404ResponseTest < SlimmerIntegrationTest
    include Rack::Test::Methods

    given_response 404, %{
      <html>
      <head><title>404 Missing</title>
      <meta name="something" content="yes">
      <meta name="x-section-name" content="This section">
      <meta name="x-section-link" content="/this_section">
      <script src="blah.js"></script>
      <link href="app.css" rel="stylesheet" type="text/css">
      </head>
      <body class="body_class">
      <div id="wrapper"><p class='message'>Something bad happened</p></div>
      </body>
      </html>
    }

    def test_should_not_replace_the_wrapper_using_the_app_response
      assert_not_rendered_in_template "Something bad happened"
    end

    def test_should_include_default_404_error_message
      assert_rendered_in_template "body .content header h1", "Oops! We can't find what you're looking for."
    end

    def test_should_replace_the_title_using_the_app_response
      assert_rendered_in_template "head title", "404 Missing"
    end
  end

  class Error406ResponseTest < SlimmerIntegrationTest
    include Rack::Test::Methods

    given_response 406, %{
      <html>
      <head><title>406 Not Acceptable</title>
      <meta name="something" content="yes">
      <meta name="x-section-name" content="This section">
      <meta name="x-section-link" content="/this_section">
      <script src="blah.js"></script>
      <link href="app.css" rel="stylesheet" type="text/css">
      </head>
      <body class="body_class">
      <div id="wrapper"><p class='message'>Something bad happened</p></div>
      </body>
      </html>
    }

    def test_should_not_replace_the_wrapper_using_the_app_response
      assert_not_rendered_in_template "Something bad happened"
    end

    def test_should_include_default_non_404_error_message
      assert_rendered_in_template "body .content header h1", "We seem to be having a problem."
    end

    def test_should_replace_the_title_using_the_app_response
      assert_rendered_in_template "head title", "406 Not Acceptable"
    end
  end
end