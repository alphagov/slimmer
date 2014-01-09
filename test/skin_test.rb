require_relative "test_helper"

describe Slimmer::Skin do

  describe "loading templates" do
    it "should be able to load the template" do
      skin = Slimmer::Skin.new asset_host: "http://example.local/"
      expected_url = "http://example.local/templates/example.html.erb"
      stub_request(:get, expected_url).to_return :body => "<foo />"

      template = skin.template 'example'

      assert_requested :get, expected_url
      assert_equal "<foo />", template
    end

    describe "should pass the GOVUK-Request-Id header when requesting the template" do
      before do
        @skin = Slimmer::Skin.new asset_host: "http://example.local/"
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

    describe "template caching" do
      it "should not cache the template by default" do
        skin = Slimmer::Skin.new asset_host: "http://example.local/"
        expected_url = "http://example.local/templates/example.html.erb"
        stub_request(:get, expected_url).to_return :body => "<foo />"

        first_access = skin.template 'example'
        second_access = skin.template 'example'

        assert_requested :get, "http://example.local/templates/example.html.erb", times: 2
      end

      it "should cache the template when requested" do
        skin = Slimmer::Skin.new asset_host: "http://example.local/", use_cache: true
        expected_url = "http://example.local/templates/example.html.erb"
        stub_request(:get, expected_url).to_return :body => "<foo />"

        first_access = skin.template 'example'
        second_access = skin.template 'example'

        assert_requested :get, "http://example.local/templates/example.html.erb", times: 1
        assert_same first_access, second_access
      end

      it "should only cache the template for 15 mins by default" do
        skin = Slimmer::Skin.new asset_host: "http://example.local/", use_cache: true
        expected_url = "http://example.local/templates/example.html.erb"
        stub_request(:get, expected_url).to_return :body => "<foo />"

        first_access = skin.template 'example'
        second_access = skin.template 'example'

        assert_requested :get, "http://example.local/templates/example.html.erb", times: 1
        assert_same first_access, second_access

        Timecop.travel( 15 * 60 - 30) do # now + 14 mins 30 secs
          third_access = skin.template 'example'
          assert_requested :get, "http://example.local/templates/example.html.erb", times: 1
          assert_same first_access, third_access
        end

        Timecop.travel( 15 * 60 + 30) do # now + 15 mins 30 secs
          fourth_access = skin.template 'example'
          assert_requested :get, "http://example.local/templates/example.html.erb", times: 2
          assert_equal first_access, fourth_access
        end
      end

      it "should allow overriding the cache ttl" do
        skin = Slimmer::Skin.new asset_host: "http://example.local/", use_cache: true, cache_ttl: 5 * 60
        expected_url = "http://example.local/templates/example.html.erb"
        stub_request(:get, expected_url).to_return :body => "<foo />"

        first_access = skin.template 'example'
        second_access = skin.template 'example'

        assert_requested :get, "http://example.local/templates/example.html.erb", times: 1
        assert_same first_access, second_access

        Timecop.travel( 5 * 60 - 30) do # now + 4 mins 30 secs
          third_access = skin.template 'example'
          assert_requested :get, "http://example.local/templates/example.html.erb", times: 1
          assert_same first_access, third_access
        end

        Timecop.travel( 5 * 60 + 30) do # now + 5 mins 30 secs
          fourth_access = skin.template 'example'
          assert_requested :get, "http://example.local/templates/example.html.erb", times: 2
          assert_equal first_access, fourth_access
        end
      end
    end

    it "should raise appropriate exception when template not found" do
      skin = Slimmer::Skin.new asset_host: "http://example.local/"
      expected_url = "http://example.local/templates/example.html.erb"
      stub_request(:get, expected_url).to_return(:status => '404')

      assert_raises(Slimmer::TemplateNotFoundException) do
        skin.template 'example'
      end
    end

    it "should raise appropriate exception when cant reach template host" do
      skin = Slimmer::Skin.new asset_host: "http://example.local/"
      expected_url = "http://example.local/templates/example.html.erb"
      stub_request(:get, expected_url).to_raise(Errno::ECONNREFUSED)

      assert_raises(Slimmer::CouldNotRetrieveTemplate) do
        skin.template 'example'
      end
    end

    it "should raise appropriate exception when hostname cannot be resolved" do
      skin = Slimmer::Skin.new asset_host: "http://non-existent.domain/"
      expected_url = "http://non-existent.domain/templates/example.html.erb"
      stub_request(:get, expected_url).to_raise(SocketError)

      assert_raises(Slimmer::CouldNotRetrieveTemplate) do
        skin.template 'example'
      end
    end
  end

  describe "parsing artefact from header" do
    before do
      @skin = Slimmer::Skin.new
      @headers = {}
      @response = stub("Response", :headers => @headers)
    end

    it "should construct and return an artefact with the parsed json" do
      data = {"foo" => "bar", "baz" => 1}
      @headers[Slimmer::Headers::ARTEFACT_HEADER] = data.to_json
      Slimmer::Artefact.expects(:new).with(data).returns(:an_artefact)
      assert_equal :an_artefact, @skin.artefact_from_header(@response)
    end

    it "should return nil if there is no artefact header" do
      assert_equal nil, @skin.artefact_from_header(@response)
    end

    it "should return nil if there is invalid JSON in the artefact header" do
      @headers[Slimmer::Headers::ARTEFACT_HEADER] = "fooey"
      assert_equal nil, @skin.artefact_from_header(@response)
    end
  end
end
