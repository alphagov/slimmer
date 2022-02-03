# Slimmer

Slimmer provides Rack middleware for applying a standard header and footer around pages
returned by a Ruby (Rack) application.

It does this by taking the page rendered by the application, extracting the contents of
a `div` with id 'wrapper' and inserting that into a `div` with the same id in one of its
templates. It also transfers various other details, such as `meta`, `script`, and `style` tags.

[View documentation](http://www.rubydoc.info/gems/slimmer)

## Use in a Rails app

Slimmer provides a Railtie so no configuration is necessary.

## Caching

Slimmer makes HTTP requests to `static` for templates. These are cached using `Rails.cache`.

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

## Use in before_action renders

If you have a non-default layout and want to render in a before_action method, note that you may have to explicitly call `slimmer_template(:your_template_name)` in the action before rendering. Rendering in a before_action immediately stops the action chain, and since slimmer usually calls slimmer_template as an after_action, it would be skipped over (and you'd get the default layout). 

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

## Licence

[MIT License](LICENCE)
