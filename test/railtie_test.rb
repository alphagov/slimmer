require_relative "test_helper"

describe Slimmer::Railtie do
  let(:app1) { TestApp1::Application }
  let(:app2) { TestApp2::Application }

  after { ENV["GOVUK_APP_NAME"] = nil }

  it "gets the app name from env when the app name is set in the environment" do
    # set the app name in the environment
    ENV["GOVUK_APP_NAME"] = "TestApp1"
    # run app using slimmer initializer
    Slimmer::Railtie.initializers.first.run(app1)

    # check that slimmer initializer sets the correct app name in config from environment
    assert_equal app1.middleware.use.first, [:use, [Slimmer::App, { app_name: "TestApp1" }], nil]
  end

  it "gets the app name from module_parent_name when the app name is not set in the environment" do
    # make sure environment does not contain app name
    ENV["GOVUK_APP_NAME"] = nil

    # set mock to return app name
    klass = MiniTest::Mock.new
    klass.expect :module_parent_name, "TestApp2"

    # run the test stubbing out the app name
    TestApp2::Application.stub :class, klass do
      # run app using slimmer initializer
      Slimmer::Railtie.initializers.first.run(app2)
      # check that slimmer initializer sets the correct app name in config from the app parent_name
      assert_equal app2.middleware.use.first, [:use, [Slimmer::App, { app_name: "TestApp2" }], nil]
    end
  end
end
