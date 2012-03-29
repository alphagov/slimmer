require 'slimmer/skin'

module Slimmer
  class Skin
    def load_template name
      logger.debug "Slimmer: TEST MODE - Loading fixture template from #{__FILE__}"
      %q{
        <html>
          <head>
            <title>Test Template</title>
            <script src="http://static.preview.alphagov.co.uk/javascripts/libs/jquery/jquery-1.7.2.min.js"></script><!-- no defer on jquery -->
            <script src="http://static.preview.alphagov.co.uk/javascripts/libs/jquery/jquery-ui-1.8.16.custom.min.js" defer></script>
            <script src="http://static.preview.alphagov.co.uk/javascripts/libs/jquery/plugins/jquery.base64.js" defer></script>
            <script src="http://static.preview.alphagov.co.uk/javascripts/libs/jquery/plugins/jquery.mustache.js" defer></script>
            <script src="http://static.preview.alphagov.co.uk/javascripts/search.js" defer></script>
            <script src="http://static.preview.alphagov.co.uk/javascripts/core.js" defer></script>
            <script src="http://static.preview.alphagov.co.uk/javascripts/devolution.js" defer></script>
            <script src="http://static.preview.alphagov.co.uk/javascripts/popup.js" defer></script>
            <script src="http://static.preview.alphagov.co.uk/javascripts/geo-locator.js" defer></script>
            <script src="http://static.preview.alphagov.co.uk/javascripts/customisation-settings.js" defer></script>
          </head>
          <body>
            <div class="header-context">Header</div>
            <div id="wrapper"></div>
          </body>
        </html>
      }
    end
  end
end
