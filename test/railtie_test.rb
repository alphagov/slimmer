require_relative "test_helper"
require "rails"

describe Slimmer::Railtie do
  it "gets the app name from env when the app name is set in the environment" do
    ClimateControl.modify(GOVUK_APP_NAME: "TestApp1") do
      app = Class.new(Rails::Application)
      middleware = Minitest::Mock.new
      middleware.expect :use, nil, [Slimmer::App, { app_name: "TestApp1" }]

      app.stub :middleware, middleware do
        Slimmer::Railtie.initializers.first.run(app)
      end
    end
  end

  it "gets the app name from module_parent_name when the app name is not set in the environment" do
    ClimateControl.modify(GOVUK_APP_NAME: nil) do
      app = Class.new(Rails::Application)
      klass = Minitest::Mock.new
      klass.expect :module_parent_name, "TestApp2"

      middleware = Minitest::Mock.new
      middleware.expect :use, nil, [Slimmer::App, { app_name: "TestApp2" }]

      app.stub :class, klass do
        app.stub :middleware, middleware do
          Slimmer::Railtie.initializers.first.run(app)
        end
      end
    end
  end
end
