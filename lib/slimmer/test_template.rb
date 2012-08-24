module Slimmer::TestTemplate
  TEMPLATE = %q{
    <html>
      <head>
        <title>Test Template</title>
        <script src="http://static.preview.alphagov.co.uk/static/libs/jquery/jquery-1.7.2.min.js"></script><!-- no defer on jquery -->
        <script src="http://static.preview.alphagov.co.uk/static/libs/jquery/jquery-ui-1.8.16.custom.min.js" defer></script>
        <script src="http://static.preview.alphagov.co.uk/static/libs/jquery/plugins/jquery.base64.js" defer></script>
        <script src="http://static.preview.alphagov.co.uk/static/libs/jquery/plugins/jquery.mustache.js" defer></script>
        <script src="http://static.preview.alphagov.co.uk/static/search.js" defer></script>
        <script src="http://static.preview.alphagov.co.uk/static/core.js" defer></script>
        <script src="http://static.preview.alphagov.co.uk/static/devolution.js" defer></script>
        <script src="http://static.preview.alphagov.co.uk/static/popup.js" defer></script>
        <script src="http://static.preview.alphagov.co.uk/static/geo-locator.js" defer></script>
        <script src="http://static.preview.alphagov.co.uk/static/customisation-settings.js" defer></script>
      </head>
      <body>
        <nav role="navigation" class="header-context">
          <ol class="group">
            <li><a href="/">Home</a></li>
            <li><a href="/browse">All sections</a></li>
          </ol>
        </nav>

        <div id="wrapper"></div>
      </body>
    </html>
  }
end
