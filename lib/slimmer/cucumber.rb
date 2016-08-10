require 'cucumber'

require 'slimmer/test'
require 'slimmer/test_helpers/shared_templates'

World(Slimmer::TestHelpers::SharedTemplates)

Before do
  stub_shared_component_locales
end
