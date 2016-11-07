require_relative "../test_helper"
require_relative "../../lib/slimmer/test_helpers/govuk_components"

describe Slimmer::TestHelpers::GovukComponents do
  let(:subject) {
    class Dummy
      include Slimmer::TestHelpers::GovukComponents
    end
  }

  describe '#shared_component_selector' do
    it 'generates a selector for components' do
      outcome = subject.new.shared_component_selector('flux_capacitor')

      expected = "test-govuk-component[data-template='govuk_component-flux_capacitor']"
      assert_equal expected, outcome
    end
  end
end
