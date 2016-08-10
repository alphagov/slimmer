module Slimmer
  module TestHelpers
    module SharedTemplates
      def stub_shared_component_locales
        stub_request(:get, /https?:\/\/\S+.gov.uk\/templates\/locales\/.+/).
          to_return(status: 400, headers: {})
        stub_request(:get, /https?:\/\/\S+.gov.uk\/templates\/locales/).
          to_return(status: 200, body: '{}', headers: {})
      end

      def shared_component_selector(name)
        "#{Slimmer::ComponentResolver::TEST_TAG_NAME}[data-template='govuk_component-#{name}']"
      end
    end
  end
end
