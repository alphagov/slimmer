module Slimmer
  # @api public
  #
  # Include this module to avoid loading components over the network
  # @example
  #   class ApplicationController < ActionController::Base
  #     include Slimmer::LocalGovukComponents
  #   end
  #
  #   # In your views:
  #
  #   <%= render partial: 'govuk_component/example_component' %>
  module LocalGovukComponents
    def self.included into
      into.before_action :add_govuk_components
    end

    # @private
    def add_govuk_components
      append_view_path LocalGovukComponents.expiring_resolver_cache.resolver
    end

    # @private
    def self.expiring_resolver_cache
      @expiring_resolver_cache ||= TimedExpirationResolverCache.new
    end

  private

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

        @resolver ||= Slimmer::LocalComponentResolver.new
      end
    end
  end
end
