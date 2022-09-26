require_relative "test_helper"
require "rails"

describe Slimmer::Railtie do
  after { ENV["GOVUK_APP_NAME"] = nil }

  it "gets the app name from env when the app name is set in the environment" do
    ENV["GOVUK_APP_NAME"] = "TestApp1"

    app = Class.new(Rails::Application)
    middleware = MiniTest::Mock.new
    middleware.expect :use, nil, [Slimmer::App, { app_name: "TestApp1" }]

    app.stub :middleware, middleware do
      Slimmer::Railtie.initializers.first.run(app)
    end
  end

  it "gets the app name from module_parent_name when the app name is not set in the environment" do
    ENV["GOVUK_APP_NAME"] = nil

    app = Class.new(Rails::Application)
    klass = MiniTest::Mock.new
    klass.expect :module_parent_name, "TestApp2"

    middleware = MiniTest::Mock.new
    middleware.expect :use, nil, [Slimmer::App, { app_name: "TestApp2" }]

    app.stub :class, klass do
      app.stub :middleware, middleware do
        Slimmer::Railtie.initializers.first.run(app)
      end
    end
  end
end
