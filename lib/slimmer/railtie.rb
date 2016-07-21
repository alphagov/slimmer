module Slimmer
  class Railtie < Rails::Railtie
    config.slimmer = ActiveSupport::OrderedOptions.new

    initializer "slimmer.configure" do |app|
      slimmer_config = app.config.slimmer.to_hash

      app_name = ENV['GOVUK_APP_NAME'] || app.class.parent_name
      slimmer_config = slimmer_config.reverse_merge(app_name: app_name)

      app.middleware.use Slimmer::App, slimmer_config

      I18n.backend = I18n::Backend::Chain.new(I18n.backend, Slimmer::I18nBackend.new)
    end
  end
end
