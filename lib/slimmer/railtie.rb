module Slimmer
  class Railtie < Rails::Railtie
    config.slimmer = ActiveSupport::OrderedOptions.new

    initializer "slimmer.configure" do |app|
      slimmer_config = app.config.slimmer.to_hash
      app_name = ENV["GOVUK_APP_NAME"] || Slimmer::Railtie.parent_name(app)
      slimmer_config = slimmer_config.reverse_merge(app_name: app_name)

      # The extra kwargs **{} is for Ruby 2.7 so that it doesn't recognise the
      # slimmer_config as kwargs, this change can be removed once Ruby 2.7
      # support is dropped
      app.middleware.use Slimmer::App, slimmer_config, **{}
    end

    # TODO: remove this method when all our apps are in rails 6 and substitute
    # it with: app_name = ENV['GOVUK_APP_NAME'] || app.class.module_parent_name
    def self.parent_name(app)
      if app.class.respond_to?(:module_parent_name)
        app.class.module_parent_name
      else
        app.class.parent_name
      end
    end
  end
end
