module Slimmer
  class Railtie < Rails::Railtie
    config.slimmer = ActiveSupport::OrderedOptions.new

    initializer "slimmer.configure" do |app|
      slimmer_config = app.config.slimmer.to_hash
      parent_name = app.class.module_parent_name if app.class.respond_to?(:module_parent_name)
      app_name = ENV.fetch("GOVUK_APP_NAME", parent_name)
      slimmer_config = slimmer_config.reverse_merge(app_name:)

      # The extra kwargs **{} is for Ruby 2.7 so that it doesn't recognise the
      # slimmer_config as kwargs, this change can be removed once Ruby 2.7
      # support is dropped
      app.middleware.use Slimmer::App, slimmer_config, **{}
    end
  end
end
