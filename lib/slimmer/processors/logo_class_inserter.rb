module Slimmer
  module Processors
    class LogoClassInserter
      LOGO_CLASSES = %w(businesslink directgov)

      def initialize(artefact)
        @artefact = artefact
      end

      def filter(source, dest)
        return unless @artefact and @artefact["tag_ids"]
        logo_classes = LOGO_CLASSES & @artefact["tag_ids"]
        wrapper = dest.css('#wrapper')
        logo_classes.each do |klass|
          wrapper.add_class(klass)
        end
      end
    end
  end
end
