require 'slimmer/skin'
require 'slimmer/test_template'

module Slimmer
  class Skin
    def load_template name
      logger.debug "Slimmer: TEST MODE - Loading fixture template from #{__FILE__}"
      if name == 'related.raw'
        %{<div id="test-related-items"></div>}
      else
        Slimmer::TestTemplate::TEMPLATE
      end
    end
  end
end
