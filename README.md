Slimmer provides rack middleware for applying a standard header and footer around pages 
returned by a ruby (rack) application. 

It does this by taking the page rendered by the application, extracting the contents of
a div with id 'wrapper' and inserting that into a div with the same id in one of its templates.
It also transfers various other details, such as meta, script, and style tags.

## Use in a Rails app

Slimmer provides a Railtie so no configuration is necessary. By default it will use the
Plek gem to look for the 'static' (previously 'assets') host for the current environment.

If you want to use your own set of templates you will need to specify the appropriate host
eg.

    YourApp::Application.configure do
      config.slimmer.asset_host = 'http://your.server.somewhere'
    end

it expects to find templates in a folder called 'templates' on that host.

## Use elsewhere

Slimmer will work as standard rack middleware:

    use Slimmer::App

or

    use Slimmer::App, :asset_host => "http://my.alternative.host"

## Asset tag helpers

To get asset tag helpers to point to your external asset server, add 

    config.action_controller.asset_host = "http://my.alternative.host"
    
to application.rb.

## Specifying a template

A specific template can be requested by giving its name in the X-Slimmer-Template HTTP header. 

In a controller action, you can do this by calling `slimmer_template`.

    class MyController < ApplicationController
      def index
        slimmer_template 'homepage'
      end
    end

There's also a macro style method which will affect all actions:

    class YourController < ApplicationController
      slimmer_template :admin
    end

To get this, include Slimmer::Template in your ApplicationController:

    class ApplicationController < ActionController::Base
      include Slimmer::Template
    end

## Logging

Slimmer can be configured with a logger by passing in a logger instance (anything that quacks like an instance of Logger).
For example to log to the Rails log, put the following in an initializer:

    YourApp::Application.configure do
      config.slimmer.logger = Rails.logger
    end

**Note:** This can't be in `application.rb` because the Rails logger hasn't been initialized by then.

**Debug logging**

By default if you pass in a logger with its log level set to debug, slimmer will dup this logger and reduce the level to info. (Slimmer's debug logging is very noisy).  To prevent this, set the `enable_debugging` option to true.  e.g. for Rails:

    YourApp::Application.configure do
      config.slimmer.enable_debugging = true
    end

## The name

Slimmer was extracted from a much larger project called 'skinner'. 'slimmer' referred to the size 
of its code compared to skinner (which also acted as an HTTP proxy and mixed in a few other 
concerns). Over time the codebase has grown a little, but the name stuck.
