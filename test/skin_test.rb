require_relative "test_helper"

describe Slimmer::Skin do

  describe "loading templates" do
    it "should be able to load the template" do
      skin = Slimmer::Skin.new asset_host: "http://example.local/", cache: Slimmer::Cache.instance

      expected_url = "http://example.local/templates/example.html.erb"
      stub_request(:get, expected_url).to_return :body => "<foo />"

      template = skin.template 'example'

      assert_requested :get, expected_url
      assert_equal "<foo />", template
    end

    describe "should pass the GOVUK-Request-Id header when requesting the template" do
      before do
        @skin = Slimmer::Skin.new asset_host: "http://example.local/", cache: Slimmer::Cache.instance

        @expected_url = "http://example.local/templates/example.html.erb"
        stub_request(:get, @expected_url).to_return :body => "<foo />"
      end

      it "should pass the value from the original request if set" do
        Slimmer::GovukRequestId.value = '12345'
        template = @skin.template('example')

        assert_requested :get, @expected_url do |request|
          request.headers['Govuk-Request-Id'] == '12345'
        end
        assert_equal "<foo />", template
      end

      it "shouldnot set the header if the value is not set" do
        Slimmer::GovukRequestId.value = ''
        template = @skin.template('example')

        assert_requested :get, @expected_url do |request|
          ! request.headers.has_key?('Govuk-Request-Id')
        end
        assert_equal "<foo />", template
      end
    end

    it "should try and load templates from the cache" do
      skin = Slimmer::Skin.new asset_host: "http://example.local/", cache: Slimmer::Cache.instance

      Slimmer::Cache.instance.expects(:fetch).with('example-template').returns('cache data')
      template = skin.template 'example-template'
      assert_equal 'cache data', template
    end

    it "should raise appropriate exception when template not found" do
      skin = Slimmer::Skin.new asset_host: "http://example.local/", cache: Slimmer::Cache.instance

      expected_url = "http://example.local/templates/example.html.erb"
      stub_request(:get, expected_url).to_return(:status => '404')

      assert_raises(Slimmer::TemplateNotFoundException) do
        skin.template 'example'
      end
    end

    it "should raise appropriate exception when cant reach template host" do
      skin = Slimmer::Skin.new asset_host: "http://example.local/", cache: Slimmer::Cache.instance

      expected_url = "http://example.local/templates/example.html.erb"
      stub_request(:get, expected_url).to_raise(Errno::ECONNREFUSED)

      assert_raises(Slimmer::CouldNotRetrieveTemplate) do
        skin.template 'example'
      end
    end

    it "should raise appropriate exception when hostname cannot be resolved" do
      skin = Slimmer::Skin.new asset_host: "http://non-existent.domain/", cache: Slimmer::Cache.instance

      expected_url = "http://non-existent.domain/templates/example.html.erb"
      stub_request(:get, expected_url).to_raise(SocketError)

      assert_raises(Slimmer::CouldNotRetrieveTemplate) do
        skin.template 'example'
      end
    end

    it "should raise appropriate exception when encountering an SSL error" do
      skin = Slimmer::Skin.new asset_host: "https://bad-ssl.domain/", cache: Slimmer::Cache.instance

      expected_url = "https://bad-ssl.domain/templates/example.html.erb"
      stub_request(:get, expected_url).to_raise(OpenSSL::SSL::SSLError)

      assert_raises(Slimmer::CouldNotRetrieveTemplate) do
        skin.template 'example'
      end
    end
  end
end
