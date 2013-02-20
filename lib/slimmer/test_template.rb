module Slimmer::TestTemplate
  TEMPLATE = %q{
    <html>
      <head>
        <title>Test Template</title>
        <script src="https://static.preview.alphagov.co.uk/static/libs/jquery/jquery-1.7.2.min.js" type="text/javascript"></script><!-- no defer on jquery -->
        <script src="https://static.preview.alphagov.co.uk/static/application.js" type="text/javascript" defer="defer"></script>
      </head>
      <body>
        <div class="header-context">
          <nav role="navigation">
            <ol class="group">
              <li><a href="/">Home</a></li>
            </ol>
          </nav>
        </div>

        <div id="wrapper"></div>
      </body>
    </html>
  }
end
