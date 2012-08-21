require 'nokogiri'
require 'erb'
require 'open-uri'
require 'plek'
require 'null_logger'
require 'openssl'

require 'slimmer/railtie' if defined? Rails

module Slimmer
  TEMPLATE_HEADER = 'X-Slimmer-Template'
  SKIP_HEADER = 'X-Slimmer-Skip'
  SEARCH_PATH_HEADER = 'X-Slimmer-Search-Path'

  autoload :Version, 'slimmer/version'
  autoload :Railtie, 'slimmer/railtie'
  autoload :Skin, 'slimmer/skin'

  autoload :Template, 'slimmer/template'
  autoload :App, 'slimmer/app'

  module Processors
    autoload :TitleInserter, 'slimmer/processors/title_inserter'
    autoload :AdminTitleInserter, 'slimmer/processors/admin_title_inserter'
    autoload :SectionInserter, 'slimmer/processors/section_inserter'
    autoload :TagMover, 'slimmer/processors/tag_mover'
    autoload :ConditionalCommentMover, 'slimmer/processors/conditional_comment_mover'
    autoload :FooterRemover, 'slimmer/processors/footer_remover'
    autoload :BodyInserter, 'slimmer/processors/body_inserter'
    autoload :BodyClassCopier, 'slimmer/processors/body_class_copier'
    autoload :UrlRewriter, 'slimmer/processors/url_rewriter'
    autoload :HeaderContextInserter, 'slimmer/processors/header_context_inserter'
    autoload :GoogleAnalyticsConfigurator, 'slimmer/processors/google_analytics_configurator'
    autoload :RelatedItemsInserter, 'slimmer/processors/related_items_inserter'
    autoload :SearchPathSetter, 'slimmer/processors/search_path_setter'
  end

  class TemplateNotFoundException < StandardError; end
  class CouldNotRetrieveTemplate < StandardError; end
end
