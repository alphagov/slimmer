module Slimmer
  class Railtie < Rails::Railtie
    config.slimmer = ActiveSupport::OrderedOptions.new
    
    initializer "slimmer.configure" do |app|
      app.middleware.use Slimmer::App, app.config.slimmer[:template_host], app.config.slimmer[:template_path]
    end
  end
end
