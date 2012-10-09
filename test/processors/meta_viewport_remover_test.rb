require_relative "../test_helper"

class MetaViewportRemover < SlimmerIntegrationTest
  TEMPLATE = <<-END
      <html>
        <head>
          <meta name="viewport" content="width=device-width, intial-scale=1">
        </head>
        <body>
          <div><div id="wrapper"></div></div>
        </body>
      </html>
    END

  def test_should_leave_all_content_as_it_is_if_there_is_not_a_meta_viewport_header_set
    given_response 200, TEMPLATE, {}
    assert_equal "<meta name=\"viewport\" content=\"width=device-width, intial-scale=1\">",
                 Nokogiri::HTML.parse(last_response.body).at_xpath('//head//meta[@name="viewport"]').to_s
  end

  def test_should_remove_the_meta_viewport_if_the_relevant_header_is_set
    given_response 200, TEMPLATE, {Slimmer::Headers::REMOVE_META_VIEWPORT => "true"}
    assert_nil Nokogiri::HTML.parse(last_response.body).at_xpath('//head//meta[@name="viewport"]')
  end
end
