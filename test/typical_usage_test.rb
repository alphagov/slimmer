require "test_helper"
require "gds_api/test_helpers/panopticon"

module TypicalUsage

  class SkippingSlimmerTest < SlimmerIntegrationTest
    given_response 200, %{Don't template me}, {"X-Slimmer-Skip" => "true"}

    def test_should_return_the_response_as_is
      assert_equal "Don't template me", last_response.body
    end
  end

  class SkipUsingQueryParamTest < SlimmerIntegrationTest
    given_response 200, %{<html><body><div id='unskinned'>Unskinned</div><div id="wrapper">Don't template me</div></body></html>}, {}

    def fetch_page; end

    def with_rails_env(new_env, &block)
      old_env, ENV['RAILS_ENV'] = ENV['RAILS_ENV'], new_env
      begin
        yield
      ensure
        ENV['RAILS_ENV'] = old_env
      end
    end

    def test_should_return_the_response_as_is_in_development
      with_rails_env('development') do
        get "/some-slug?skip_slimmer=1"
      end
      assert_rendered_in_template '#unskinned', "Unskinned"
    end

    def test_not_skip_slimmer_in_production
      with_rails_env('production') do
        get "/some-slug?skip_slimmer=1"
      end
      assert_rendered_in_template '#wrapper', "Don't template me"
    end
  end

  class SkipNonHtmlResponse < SlimmerIntegrationTest
    given_response 200, '{ "json" : "document" }', {'Content-Type' => 'application/json'}

    def test_should_pass_through_non_html_response
      assert_equal '{ "json" : "document" }', last_response.body
    end
  end

  class ContentLengthTest < SlimmerIntegrationTest
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

    def test_should_set_correct_content_length_header
      assert_equal "791", last_response.headers['Content-Length']
    end

  end

  class NormalResponseTest < SlimmerIntegrationTest
    given_response 200, %{
      <html>
      <head><title>The title of the page</title>
      <meta name="something" content="yes">
      <meta name="x-section-name" content="This section">
      <meta name="x-section-link" content="/this_section">
      <script src="blah.js"></script>
      <!--[if lt IE 9]><link href="app-ie.css" rel="stylesheet" type="text/css"><![endif]-->
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

    def test_should_move_conditional_comments_into_the_head
      element = Nokogiri::HTML.parse(last_response.body).at_xpath('//comment()')
      assert_match /app-ie\.css/, element.to_s, 'Not found conditional comment in output'
    end

    def test_should_copy_the_class_of_the_body_element
      assert_rendered_in_template "body.body_class"
    end

    def test_should_insert_meta_navigation_links_into_the_navigation
      assert_rendered_in_template "nav[role=navigation] li a[href='/this_section']", "This section"
    end

  end

  class ResponseWithRelatedItemsTest < SlimmerIntegrationTest
    include GdsApi::TestHelpers::Panopticon

    def setup
      panopticon_has_metadata(
        'slug' => 'some-slug',
        'title' => 'Example document',
        'related_items' => [
            {
            'artefact' => {
              'kind' => 'guide',
              'name' => 'How to test computer software automatically & ensure that 2>1',
              'slug' => 'how-to-test-computer-software-automatically',
              }
            }
          ]
        )
      super
    end
  end

  class CitizenRelatedItemsTest < ResponseWithRelatedItemsTest
    given_response 200, %{
      <html>
      <body class="citizen">
      <div id="wrapper">The body of the page<div id="related-items"></div></div>
      </body>
      </html>
    }, {}

    def fetch_page
      get "/some-slug"
    end

    def test_should_insert_related_items_block
      assert_rendered_in_template "div.related nav li.guide a", "How to test computer software automatically &amp; ensure that 2&gt;1"
      assert_rendered_in_template "div.related nav li.guide", %r{href="/how-to-test-computer-software-automatically"}
    end
  end

  class NonCitizentRelatedItemsTest < ResponseWithRelatedItemsTest
    given_response 200, %{
      <html>
      <body class="noncitizen">
      <div id="wrapper">The body of the page<div id="related-items"></div></div>
      </body>
      </html>
    }, {}

    def fetch_page
      get "/some-slug"
    end

    def test_should_not_insert_related_items_block
      assert_rendered_in_template "div#related-items", ""
    end
  end

  class HeaderContextResponseTest < SlimmerIntegrationTest
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
      <div class="header-context custom-class">app-specific header context</div>
      <div id="wrapper">The body of the page</div>
      </body>
      </html>
    }

    def test_should_replace_the_header_context_using_the_app_response
      assert_rendered_in_template ".header-context.custom-class", "app-specific header context"
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

  class ApiTimeoutResponseTest < SlimmerIntegrationTest
    include Rack::Test::Methods

    given_response 200, %{
      <html>
      <head><title>The title of the page</title>
      <meta name="something" content="yes">
      <meta name="x-section-name" content="This section">
      <meta name="x-section-link" content="/this_section">
      <script src="blah.js"></script>
      <link href="app.css" rel="stylesheet" type="text/css">
      </head>
      <body class="body_class citizen">
      <div id="wrapper">The body of the page</div>
      <div id="related-items"></div>
      </body>
      </html>
    }

    def setup
      ::Slimmer::RelatedItemsInserter.any_instance.stubs(:metadata_from_panopticon).raises(GdsApi::TimedOutException)
      super
    end

    def test_should_return_503_if_an_API_call_times_out
      assert_equal 503, last_response.status
    end
  end

  class ArbitraryWrapperIdTest < SlimmerIntegrationTest

    given_response 200, %{
      <html>
      <body>
      <div id="custom_wrapper">The body of the page</div>
      </body>
      </html>
    }, {}, {wrapper_id: "custom_wrapper"}

    def test_should_replace_wrapper_with_custom_wrapper
      assert_rendered_in_template "body .content #custom_wrapper", "The body of the page"
      assert_no_selector "#wrapper"
    end
  end
end
