module Slimmer
  module Template
    def self.included into
      into.extend ClassMethods
    end

    module ClassMethods
      def slimmer_template template_name
        after_filter do
          response.headers[Slimmer::Headers::TEMPLATE_HEADER] = template_name.to_s
        end
      end
    end
  end
end
