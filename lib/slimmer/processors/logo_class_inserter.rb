module Slimmer
  module Processors
    class LogoClassInserter
      LOGO_CLASSES = %w(businesslink directgov)

      def initialize(artefact)
        @artefact = artefact
      end

      def filter(source, dest)
        return unless @artefact and @artefact["tags"]
        classes_to_use = LOGO_CLASSES & legacy_sources
        wrapper = dest.css('#wrapper')
        classes_to_use.each do |klass|
          wrapper.add_class(klass)
        end
      end

      def legacy_sources
        legacy_source_tags = @artefact["tags"].select do |tag| 
          tag["details"]["type"] == "legacy_source"
        end
        legacy_sources = legacy_source_tags.map do |tag| 
          tag["id"].split("/").last.chomp(".json")
        end
        legacy_sources
      end
    end
  end
end
