require_relative "test_helper"

describe Slimmer::Skin do
  describe "loading templates" do
    it "should be able to load the template" do
      skin = Slimmer::Skin.new asset_host: "http://example.local/"

      expected_url = "http://example.local/templates/example.html.erb"
      stub_request(:get, expected_url).to_return body: "<foo />"

      template = skin.template "example"

      assert_requested :get, expected_url
      assert_equal "<foo />", template
    end

    describe "passes the GOVUK-Request-Id header when requesting the template" do
      it "passes the value from the original request if set" do
        @skin = Slimmer::Skin.new asset_host: "http://example.local/"

        @expected_url = "http://example.local/templates/example.html.erb"
        stub_request(:get, @expected_url).to_return body: "<foo />"

        Slimmer::GovukRequestId.value = "12345"
        template = @skin.template("example")

        assert_requested :get, @expected_url do |request|
          request.headers["Govuk-Request-Id"] == "12345"
        end
        assert_equal "<foo />", template
      end
    end

    it "should raise appropriate exception when template not found" do
      skin = Slimmer::Skin.new asset_host: "http://example.local/"

      expected_url = "http://example.local/templates/example.html.erb"
      stub_request(:get, expected_url).to_return(status: 404)

      assert_raises(Slimmer::TemplateNotFoundException) do
        skin.template "example"
      end
    end

    it "should raise appropriate exception for intermittent errors" do
      skin = Slimmer::Skin.new asset_host: "http://example.local/"

      expected_url = "http://example.local/templates/example.html.erb"
      stub_request(:get, expected_url).to_return(status: 504)

      assert_raises(Slimmer::IntermittentRetrievalError) do
        skin.template "example"
      end
    end

    it "should raise appropriate exception when cant reach template host" do
      skin = Slimmer::Skin.new asset_host: "http://example.local/"

      expected_url = "http://example.local/templates/example.html.erb"
      stub_request(:get, expected_url).to_raise(Errno::ECONNREFUSED)

      assert_raises(Slimmer::CouldNotRetrieveTemplate) do
        skin.template "example"
      end
    end

    it "should raise appropriate exception when hostname cannot be resolved" do
      skin = Slimmer::Skin.new asset_host: "http://non-existent.domain/"

      expected_url = "http://non-existent.domain/templates/example.html.erb"
      stub_request(:get, expected_url).to_raise(SocketError)

      assert_raises(Slimmer::CouldNotRetrieveTemplate) do
        skin.template "example"
      end
    end

    it "should raise appropriate exception when encountering an SSL error" do
      skin = Slimmer::Skin.new asset_host: "https://bad-ssl.domain/"

      expected_url = "https://bad-ssl.domain/templates/example.html.erb"
      stub_request(:get, expected_url).to_raise(OpenSSL::SSL::SSLError)

      assert_raises(Slimmer::CouldNotRetrieveTemplate) do
        skin.template "example"
      end
    end
  end
end
