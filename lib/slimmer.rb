require 'nokogiri'
require 'erb'
require 'open-uri'
require 'plek'
require 'null_logger'
require 'openssl'

require 'slimmer/version'
require 'slimmer/railtie' if defined? Rails

module Slimmer

  autoload :Railtie, 'slimmer/railtie'
  autoload :Skin, 'slimmer/skin'

  autoload :Template, 'slimmer/template'
  autoload :App, 'slimmer/app'
  autoload :Headers, 'slimmer/headers'

  module Processors
    autoload :AdminTitleInserter, 'slimmer/processors/admin_title_inserter'
    autoload :BodyClassCopier, 'slimmer/processors/body_class_copier'
    autoload :BodyInserter, 'slimmer/processors/body_inserter'
    autoload :ConditionalCommentMover, 'slimmer/processors/conditional_comment_mover'
    autoload :FooterRemover, 'slimmer/processors/footer_remover'
    autoload :GoogleAnalyticsConfigurator, 'slimmer/processors/google_analytics_configurator'
    autoload :HeaderContextInserter, 'slimmer/processors/header_context_inserter'
    autoload :LogoClassInserter, 'slimmer/processors/logo_class_inserter'
    autoload :RelatedItemsInserter, 'slimmer/processors/related_items_inserter'
    autoload :SearchPathSetter, 'slimmer/processors/search_path_setter'
    autoload :SectionInserter, 'slimmer/processors/section_inserter'
    autoload :TagMover, 'slimmer/processors/tag_mover'
    autoload :TitleInserter, 'slimmer/processors/title_inserter'
  end

  class TemplateNotFoundException < StandardError; end
  class CouldNotRetrieveTemplate < StandardError; end
end
