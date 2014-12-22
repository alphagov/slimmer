require_relative "../test_helper"
require_relative "../../lib/slimmer/test_helpers/shared_templates"

describe Slimmer::TestHelpers::SharedTemplates do

  let(:subject) {
    class Dummy
      include Slimmer::TestHelpers::SharedTemplates
    end
    }

  describe 'shared_component_selector' do
    it 'should generate a selector for components' do
      outcome = subject.new.shared_component_selector('flux_capacitor')
      expected = "test-govuk-component[data-template='govuk_component-flux_capacitor']"
      assert_equal expected, outcome
    end
  end
end
