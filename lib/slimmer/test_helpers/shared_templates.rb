module Slimmer
  module TestHelpers
    module SharedTemplates
      def shared_component_selector(name)
        "test-govuk-component[data-template='govuk_component-#{name}']"
      end
    end
  end
end
