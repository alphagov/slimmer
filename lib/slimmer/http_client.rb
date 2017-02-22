require "slimmer/govuk_request_id"
require "restclient"

module Slimmer
  class HTTPClient
    def self.get(url)
      headers = {
        user_agent: "slimmer/#{Slimmer::VERSION} (#{ENV['GOVUK_APP_NAME']})",
        govuk_request_id: GovukRequestId.value,
      }

      response = RestClient.get(url, headers)
      response.body
    end
  end
end
