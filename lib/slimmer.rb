require 'slimmer/version'

require 'slimmer/template'
require 'slimmer/app'
require 'slimmer/title_inserter'
require 'slimmer/admin_title_inserter'
require 'slimmer/section_inserter'
require 'slimmer/tag_mover'
require 'slimmer/footer_remover'
require 'slimmer/skin'
require 'slimmer/body_inserter'
require 'slimmer/body_class_copier'
require 'slimmer/url_rewriter'

require 'slimmer/railtie' if defined?(Rails)

require 'nokogiri'
require 'erb'
require 'open-uri'
require 'plek'

module Slimmer
  TEMPLATE_HEADER = 'X-Slimmer-Template'
  SKIP_HEADER = 'X-Slimmer-Skip'
end
