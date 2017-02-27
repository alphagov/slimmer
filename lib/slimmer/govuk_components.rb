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
      append_view_path GovukComponents.expiring_resolver_cache.resolver

      return if slimmer_backend_included?
      I18n.backend = I18n::Backend::Chain.new(I18n.backend, Slimmer::I18nBackend.new)
    end

    # @private
    def self.expiring_resolver_cache
      @expiring_resolver_cache ||= TimedExpirationResolverCache.new
    end

  private

    def slimmer_backend_included?
      I18n.backend.is_a?(I18n::Backend::Chain) &&
        I18n.backend.backends.any? { |b| b.is_a? Slimmer::I18nBackend }
    end

    # Slimmer::ComponentResolver instantiates a lot of large objects and leaks
    # memory. This class will cache the resolver so that it doesn't have to
    # create new ActionView::Template objects for each request. The cache is
    # timed to allow frontends to pick up changes made to components in `static`.
    class TimedExpirationResolverCache
      def initialize
        @cache_last_reset = Time.now
      end

      def resolver
        if (@cache_last_reset + Slimmer::CACHE_TTL) < Time.now
          @resolver = nil
          @cache_last_reset = Time.now
        end

        @resolver ||= Slimmer::ComponentResolver.new
      end
    end
  end
end
