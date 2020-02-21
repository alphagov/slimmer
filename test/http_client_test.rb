require_relative "test_helper"

describe Slimmer::HTTPClient do
  describe ".get" do
    it "adds the correct user agent header" do
      ENV["GOVUK_APP_NAME"] = "my-app"

      request = stub_request(:get, "https://example.com/").
        with(headers: { "User-Agent" => "slimmer/#{Slimmer::VERSION} (my-app)" }).
        to_return(status: 200)

      Slimmer::HTTPClient.get("https://example.com")

      assert_requested(request)
    end
  end
end
