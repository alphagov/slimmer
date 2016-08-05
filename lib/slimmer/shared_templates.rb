module Slimmer
  module SharedTemplates
    def self.included into
      into.before_action :add_shared_templates
    end

    def add_shared_templates
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
