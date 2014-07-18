module Slimmer
  module TestHelpers
    module SharedTemplates
      def shared_component_selector(name)
        "div[class='govuk_component-#{name}']"
      end
    end
  end
end
