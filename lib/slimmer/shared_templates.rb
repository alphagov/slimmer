module Slimmer
  module SharedTemplates
    def self.included into
      into.before_filter :add_shared_templates
    end

    def add_shared_templates
      append_view_path Slimmer::ComponentResolver.new
    end
  end
end
