Slimmer provides rack middleware for applying a standard header and footer around pages 
returned by a ruby (rack) application. 

It does this by taking the page rendered by the application, extracting the contents of
a div with id 'wrapper' and inserting that into one of its templates. It also transfers
various other details, such as meta, script, and style tags.

## Use in a Rails app

Slimmer provides a Railtie so no configuration is necessary should you want to use one
of the supplied templates. If you want to use your own set of templates you will need
to specify the appropriate path or host (slimmer can load templates over http) eg.

    YourApp::Application.configure do
      config.slimmer.template_path = '/place/on/file/system'
    end

    YourApp::Application.configure do
      config.slimmer.template_host = 'http://your.server.somewhere'
    end

it expects to find templates in a folder called 'templates' on that host or in that folder

## Use elsewhere

Slimmer will work as standard rack middleware:

    use Slimmer::App

or

    use Slimmer::App, :template_path => "/path/to/my/templates"

## Specifying a template

A specific template can be requested by giving its name in the X-Slimmer-Template HTTP header

eg in a rails app

    class MyController < ApplicationController
      def index
        headers['X-Slimmer-Template'] = 'homepage'
      end
    end

There's also a macro style method:

    class YourController < ApplicationController
      slimmer_template :admin
    end

To get this, include Slimmer::Template in your controller:

    class ApplicationController < ActionController::Base
      include Slimmer::Template
    end

## The name

Slimmer was extracted from a much larger project called 'skinner'. 'slimmer' referred to the size 
of its code compared to skinner (which also acted as an HTTP proxy and mixed in a few other 
concerns). Over time the codebase has grown a little, but the name stuck.

## Python

The repository also includes a python version but this is not currently maintained.
