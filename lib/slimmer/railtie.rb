module Slimmer
  class Railtie < Rails::Railtie
    config.slimmer = ActiveSupport::OrderedOptions.new

    initializer "slimmer.configure" do |app|
      slimmer_config = app.config.slimmer.to_hash

      app_name = ENV["GOVUK_APP_NAME"] || module_parent_name
      slimmer_config = slimmer_config.reverse_merge(app_name: app_name)

      app.middleware.use Slimmer::App, slimmer_config
    end

  private

    # TODO: remove this method when all our apps are in rails 6 and substitute
    # it with: app_name = ENV['GOVUK_APP_NAME'] || app.class.module_parent_name
    def module_parent_name
      if app.class.respond_to?(:module_parent_name)
        app.class.module_parent_name
      else
        app.class.parent_name
      end
    end
  end
end
