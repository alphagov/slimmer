module Slimmer
  module SharedTemplates
    def self.included into
      into.before_action :add_shared_templates
    end

    def add_shared_templates
      I18n.backend = I18n::Backend::Chain.new(I18n.backend, Slimmer::I18nBackend.new)

      append_view_path Slimmer::ComponentResolver.new
    end
  end
end
