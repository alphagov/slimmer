module Slimmer
  class GovukRequestId
    class << self
      def value
        Thread.current[:slimmer_govuk_request_id]
      end

      def value=(new_id)
        Thread.current[:slimmer_govuk_request_id] = new_id
      end
    end
  end
end
