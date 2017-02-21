module Slimmer
  class HTTPClient
    def self.get(url)
      headers = {}
      headers[:govuk_request_id] = GovukRequestId.value if GovukRequestId.set?
      response = RestClient.get(url, headers)
      response.body
    end
  end
end
