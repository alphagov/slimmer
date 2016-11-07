require 'rspec/core'

require 'slimmer'
require 'slimmer/test'
require 'slimmer/test_helpers/govuk_components'

RSpec.configure do |config|
  config.include Slimmer::TestHelpers::GovukComponents

  config.before { stub_shared_component_locales }
end
