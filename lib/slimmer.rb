require "nokogiri"
require "erb"
require "plek"
require "null_logger"

require "slimmer/version"
require "slimmer/railtie" if defined? Rails

module Slimmer
  CACHE_TTL = 60

  def self.cache=(cache)
    @cache = cache
  end

  def self.cache
    @cache ||= defined?(Rails) ? Rails.cache : NoCache.new
  end

  class NoCache
    def fetch(*)
      yield
    end
  end

  autoload :Railtie, "slimmer/railtie"
  autoload :Skin, "slimmer/skin"

  autoload :Template, "slimmer/template"
  autoload :App, "slimmer/app"
  autoload :Headers, "slimmer/headers"
  autoload :HTTPClient, "slimmer/http_client"

  module Processors
    autoload :AccountsShower, "slimmer/processors/accounts_shower"
    autoload :BodyClassCopier, "slimmer/processors/body_class_copier"
    autoload :BodyInserter, "slimmer/processors/body_inserter"
    autoload :ConditionalCommentMover, "slimmer/processors/conditional_comment_mover"
    autoload :FeedbackURLSwapper, "slimmer/processors/feedback_url_swapper"
    autoload :MetadataInserter, "slimmer/processors/metadata_inserter"
    autoload :NonceInserter, "slimmer/processors/nonce_inserter"
    autoload :HeaderContextInserter, "slimmer/processors/header_context_inserter"
    autoload :InsideHeaderInserter, "slimmer/processors/inside_header_inserter"
    autoload :SearchPathSetter, "slimmer/processors/search_path_setter"
    autoload :SearchParameterInserter, "slimmer/processors/search_parameter_inserter"
    autoload :SearchRemover, "slimmer/processors/search_remover"
    autoload :TagMover, "slimmer/processors/tag_mover"
    autoload :TitleInserter, "slimmer/processors/title_inserter"
  end

  class CouldNotRetrieveTemplate < StandardError; end
  class TemplateNotFoundException < CouldNotRetrieveTemplate; end
  class IntermittentRetrievalError < CouldNotRetrieveTemplate; end
end
