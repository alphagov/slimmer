require 'rspec/core'

require 'slimmer'
require 'slimmer/test'
require 'slimmer/test_helpers/shared_templates'

RSpec.configure do |config|
  config.include Slimmer::TestHelpers::SharedTemplates

  config.before { stub_shared_component_locales }
end
