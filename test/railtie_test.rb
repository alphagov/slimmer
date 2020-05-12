require_relative "test_helper"

describe Slimmer::Railtie do
  let(:app1) { TestApp1::Application }
  let(:app2) { TestApp2::Application }

  after { ENV["GOVUK_APP_NAME"] = nil }

  it "gets the app name from env when the app name is set in the environment" do
    ENV["GOVUK_APP_NAME"] = "TestApp1"

    Slimmer::Railtie.initializers.first.run(app1)

    middleware = MiniTest::Mock.new
    middleware.expect :use, nil, [Slimmer::App, { app_name: "TestApp1" }]

    # The 'use' method is meant to be a setter, but happens to return the underlying array of
    # lambda proxies, of which we're assuming the first one is Slimmer::App. Each lambda proxy
    # takes a 'real' middleware and repeats the same call to 'use' on it. We should avoid using
    # this pattern in other tests, and investigate some other way to test our config.
    app1.middleware.use.first.call(middleware)
  end

  it "gets the app name from module_parent_name when the app name is not set in the environment" do
    ENV["GOVUK_APP_NAME"] = nil

    klass = MiniTest::Mock.new
    klass.expect :module_parent_name, "TestApp2"

    middleware = MiniTest::Mock.new
    middleware.expect :use, nil, [Slimmer::App, { app_name: "TestApp2" }]

    TestApp2::Application.stub :class, klass do
      Slimmer::Railtie.initializers.first.run(app2)
      # The 'use' method is meant to be a setter, but happens to return the underlying array of
      # lambda proxies, of which we're assuming the first one is Slimmer::App. Each lambda proxy
      # takes a 'real' middleware and repeats the same call to 'use' on it. We should avoid using
      # this pattern in other tests, and investigate some other way to test our config.
      app2.middleware.use.first.call(middleware)
    end
  end
end
