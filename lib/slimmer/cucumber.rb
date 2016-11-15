require 'cucumber'

require 'slimmer/test'
require 'slimmer/test_helpers/govuk_components'

World(Slimmer::TestHelpers::GovukComponents)

Before do
  stub_shared_component_locales
end
