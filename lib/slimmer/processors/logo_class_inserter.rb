module Slimmer
  module Processors
    class LogoClassInserter
      LOGO_CLASSES = %w(businesslink directgov)

      def initialize(artefact)
        @artefact = artefact
      end

      def filter(source, dest)
        return unless @artefact
        classes_to_use = LOGO_CLASSES & @artefact.legacy_sources
        wrapper = dest.css('#wrapper')
        classes_to_use.each do |klass|
          wrapper.add_class(klass)
        end
      end
    end
  end
end
