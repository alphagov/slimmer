require 'nokogiri'
require 'erb'
require 'plek'
require 'null_logger'

require 'slimmer/version'
require 'slimmer/railtie' if defined? Rails

module Slimmer

  autoload :Railtie, 'slimmer/railtie'
  autoload :Skin, 'slimmer/skin'

  autoload :Cache, 'slimmer/cache'

  autoload :Template, 'slimmer/template'
  autoload :App, 'slimmer/app'
  autoload :Headers, 'slimmer/headers'
  autoload :Artefact, 'slimmer/artefact'

  autoload :SharedTemplates, 'slimmer/shared_templates'
  autoload :ComponentResolver, 'slimmer/component_resolver'

  module Processors
    autoload :BodyClassCopier, 'slimmer/processors/body_class_copier'
    autoload :BodyInserter, 'slimmer/processors/body_inserter'
    autoload :ConditionalCommentMover, 'slimmer/processors/conditional_comment_mover'
    autoload :FooterRemover, 'slimmer/processors/footer_remover'
    autoload :GoogleAnalyticsConfigurator, 'slimmer/processors/google_analytics_configurator'
    autoload :MetadataInserter, 'slimmer/processors/metadata_inserter'
    autoload :HeaderContextInserter, 'slimmer/processors/header_context_inserter'
    autoload :NavigationMover, 'slimmer/processors/navigation_mover'
    autoload :MetaViewportRemover, 'slimmer/processors/meta_viewport_remover'
    autoload :RelatedItemsInserter, 'slimmer/processors/related_items_inserter'
    autoload :ReportAProblemInserter, 'slimmer/processors/report_a_problem_inserter'
    autoload :SearchIndexSetter, 'slimmer/processors/search_index_setter'
    autoload :SearchPathSetter, 'slimmer/processors/search_path_setter'
    autoload :SearchParameterInserter, 'slimmer/processors/search_parameter_inserter'
    autoload :SectionInserter, 'slimmer/processors/section_inserter'
    autoload :TagMover, 'slimmer/processors/tag_mover'
    autoload :TitleInserter, 'slimmer/processors/title_inserter'
  end

  class TemplateNotFoundException < StandardError; end
  class CouldNotRetrieveTemplate < StandardError; end
end
