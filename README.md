# Slimmer

Slimmer provides Rack middleware for applying a standard header and footer around pages
returned by a Ruby (Rack) application.

It does this by taking the page rendered by the application, extracting the contents of
a `div` with id 'wrapper' and inserting that into a `div` with the same id in one of its
templates. It also transfers various other details, such as `meta`, `script`, and `style` tags.

## Use in a Rails app

Slimmer provides a Railtie so no configuration is necessary. By default it will use the
Plek gem to look for the 'static' (previously 'assets') host for the current environment.

If you want to use your own set of templates you will need to specify the appropriate host
eg.

```rb
YourApp::Application.configure do
  config.slimmer.asset_host = 'http://your.server.somewhere'
end
```

it expects to find templates in a folder called 'templates' on that host.

## Use elsewhere

Slimmer will work as standard rack middleware:

```rb
use Slimmer::App
```

or

```rb
use Slimmer::App, :asset_host => "http://my.alternative.host"
```

## Asset tag helpers

To get asset tag helpers to point to your external asset server, add

```rb
config.action_controller.asset_host = "http://my.alternative.host"
```
    
to `application.rb`.

## Specifying a template

A specific template can be requested by giving its name in the `X-Slimmer-Template` HTTP header.

In a controller action, you can do this by calling `slimmer_template`.

```rb
class MyController < ApplicationController
  def index
    slimmer_template 'homepage'
  end
end
```

There's also a macro style method which will affect all actions:

```rb
class YourController < ApplicationController
  slimmer_template :admin
end
```

To get this, include Slimmer::Template in your ApplicationController:

```rb
class ApplicationController < ActionController::Base
  include Slimmer::Template
end
```

## Logging

Slimmer can be configured with a logger by passing in a logger instance
(anything that quacks like an instance of `Logger`). For example, to log
to the Rails log, put the following in an initializer:

```rb
YourApp::Application.configure do
  config.slimmer.logger = Rails.logger
end
```

**Note:** This can't be in `application.rb` because the Rails logger hasn't been initialized by then.

**Debug logging**

By default if you pass in a logger with its log level set to `debug`, slimmer will dup this logger and reduce the level to `info`. (Slimmer's debug logging is very noisy).  To prevent this, set the `enable_debugging` option to true.  e.g. for Rails:

```rb
YourApp::Application.configure do
  config.slimmer.enable_debugging = true
end
```

## Shared components

To use shared template components you need to include the shared template resolver

```rb
class ApplicationController < ActionController::Base
  include Slimmer::SharedTemplates
end
```

This will make calls out to static when you try and render a partial prefixed with `govuk-component`:

```erb
<%= render partial: 'govuk-component/example_component' %>
```

You will need a copy of static running for the templates to be loaded from.

### Testing shared components

In test mode (when `Rails.env.test?` returns `true`), shared components are not
fetched from Static. Instead they are rendered as a dummy tag which contains a
JSON dump of the `locals` - the arguments passed to the component.

A test helper is included which returns a CSS selector for finding a given
component to assert that it was used. You can make it available in your tests
with:

```rb
require 'slimmer/test_helpers/shared_templates'
include Slimmer::TestHelpers::SharedTemplates
```

And then assert that the component has been used:

```rb
page.should have_css(shared_component_selector('metadata'))
```

Or look for one of the arguments to the component which will have been
`JSON.dump`ed inside the tag:

```rb
within(shared_component_selector('title')) do
  expect(page).to have_content(expected_title_text)
end
```

### Cucumber

Add the following code to features/support:

```rb
require 'slimmer/cucumber'
```

### RSpec

Add the following code to spec/spec_helper:

```rb
require 'slimmer/rspec'
```

## The name

Slimmer was extracted from a much larger project called 'skinner'. 'slimmer' referred to the size
of its code compared to skinner (which also acted as an HTTP proxy and mixed in a few other
concerns). Over time the codebase has grown a little, but the name stuck.
