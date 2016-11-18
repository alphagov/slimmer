module Slimmer
  # @api public
  #
  # Include this module to add the GOV.UK Components to your app.
  # @example
  #   class ApplicationController < ActionController::Base
  #     include Slimmer::GovukComponents
  #   end
  #
  #   # In your views:
  #
  #   <%= render partial: 'govuk_component/example_component' %>
  module GovukComponents
    def self.included into
      into.before_action :add_govuk_components
    end

    # @private
    def add_govuk_components
      append_view_path Slimmer::ComponentResolver.new

      return if slimmer_backend_included?
      I18n.backend = I18n::Backend::Chain.new(I18n.backend, Slimmer::I18nBackend.new)
    end

  private

    def slimmer_backend_included?
      I18n.backend.is_a?(I18n::Backend::Chain) &&
        I18n.backend.backends.any? { |b| b.is_a? Slimmer::I18nBackend }
    end
  end
end
