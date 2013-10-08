require 'slimmer/skin'

module Slimmer
  class Skin
    def load_template name
      logger.debug "Slimmer: TEST MODE - Loading fixture template from #{__FILE__}"
      if name =~ /\A(.*)\.raw\z/
        %{<div id="test-#{$1}"></div>}
      elsif File.exist?(template_path = File.join(File.dirname(__FILE__), 'test_templates', "#{name}.html"))
        File.read(template_path)
      else
        File.read(File.join(File.dirname(__FILE__), 'test_templates', "wrapper.html"))
      end
    end
  end
end
