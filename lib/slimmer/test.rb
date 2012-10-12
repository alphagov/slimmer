require 'slimmer/skin'
require 'slimmer/test_template'

module Slimmer
  class Skin
    def load_template name
      logger.debug "Slimmer: TEST MODE - Loading fixture template from #{__FILE__}"
      if name =~ /\A(.*)\.raw\z/
        %{<div id="test-#{$1}"></div>}
      else if name == "campaign"
        %{<section class="black" id="campaign-notification"><div><p>You've got notifications!</p></div></section>}
      else
        Slimmer::TestTemplate::TEMPLATE
      end
    end
  end
end
