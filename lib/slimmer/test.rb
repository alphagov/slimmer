require 'slimmer/skin'

module Slimmer
  class Skin
    def load_template name
      %q{
        <html>
          <head>
            <title>Test Template</title>
            <script src="http://static.preview.alphagov.co.uk/javascripts/libs/jquery/jquery-1.6.2.min.js"></script><!-- no defer on jquery -->
            <script src="http://static.preview.alphagov.co.uk/javascripts/libs/jquery/jquery-ui-1.8.16.custom.min.js" defer></script>
            <script src="http://static.preview.alphagov.co.uk/javascripts/libs/jquery/plugins/jquery.base64.js" defer></script>
            <script src="http://static.preview.alphagov.co.uk/javascripts/search.js" defer></script>
            <script src="http://static.preview.alphagov.co.uk/javascripts.preview.alphagov.lution.js" defer></script>
            <script src="http://static.preview.alphagov.co.uk/javascripts/popup.js" defer></script>
            <script src="http://static.preview.alphagov.co.uk/javascripts/feedback.js" defer></script>
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
