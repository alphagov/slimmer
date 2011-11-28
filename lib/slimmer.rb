require 'nokogiri'
require 'erb'
require 'open-uri'
require 'plek'

module Slimmer
  TEMPLATE_HEADER = 'X-Slimmer-Template'
  SKIP_HEADER = 'X-Slimmer-Skip'

  autoload :Version, 'slimmer/version'
  autoload :Railtie, 'slimmer/railtie'
  autoload :Skin, 'slimmer/skin'

  autoload :Template, 'slimmer/template'
  autoload :App, 'slimmer/app'
  autoload :TitleInserter, 'slimmer/title_inserter'
  autoload :AdminTitleInserter, 'slimmer/admin_title_inserter'
  autoload :SectionInserter, 'slimmer/section_inserter'
  autoload :TagMover, 'slimmer/tag_mover'
  autoload :FooterRemover, 'slimmer/footer_remover'
  autoload :BodyInserter, 'slimmer/body_inserter'
  autoload :BodyClassCopier, 'slimmer/body_class_copier'
  autoload :UrlRewriter, 'slimmer/url_rewriter'
  autoload :HeaderContextInserter, 'slimmer/header_context_inserter'
end
