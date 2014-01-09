module Slimmer
  class GovukRequestId
    class << self
      def set?
        !(value.nil? || value.empty?)
      end

      def value
        Thread.current[:slimmer_govuk_request_id]
      end

      def value=(new_id)
        Thread.current[:slimmer_govuk_request_id] = new_id
      end
    end
  end
end

