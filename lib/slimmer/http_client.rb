module Slimmer
  class HTTPClient
    def self.get(url)
      headers = {
        govuk_request_id: GovukRequestId.value,
      }

      response = RestClient.get(url, headers)
      response.body
    end
  end
end
