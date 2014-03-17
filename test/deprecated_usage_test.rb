require_relative "test_helper"

module DeprecatedUsage
  class BetaNoticeInserterTest < SlimmerIntegrationTest
    def test_should_add_beta_warnings
      Slimmer::Processors::BetaNoticeInserter.any_instance.
                                              expects(:warn).
                                              with(regexp_matches(/BETA_HEADER is deprecated. Use BETA_LABEL instead/))

      given_response 200, %{
        <html>
          <body class="wibble">
            <div id="wrapper">The body of the page</div>
          </body>
        </html>
      }, {Slimmer::Headers::BETA_HEADER => '1'}

      # beta notice after cookie bar
      assert_rendered_in_template "body.beta.wibble #global-header + div.beta-notice"

      # beta notice before footer
      assert_rendered_in_template "body.beta.wibble div.beta-notice.js-footer + #footer"
    end
  end
end
