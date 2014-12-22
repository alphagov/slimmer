module Slimmer
  module TestHelpers
    module SharedTemplates
      def shared_component_selector(name)
        "#{Slimmer::ComponentResolver::TEST_TAG_NAME}[data-template='govuk_component-#{name}']"
      end
    end
  end
end
