module Slimmer
  module GovukComponents
    def self.included into
      into.before_action :add_govuk_components
    end

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
