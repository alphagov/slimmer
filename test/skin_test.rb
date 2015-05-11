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

    describe "strict mode" do
      let(:invalid_html) { '<html><div id="foo"></div><div id="foo"></div></html>' }
      let(:rack_env) { 'production' }

      before do
        ENV["RACK_ENV"] = rack_env
      end

      after do
        ENV["RACK_ENV"] = "test"
      end

      subject do
        skin = Slimmer::Skin.new strict: strict_mode

        skin.parse_html invalid_html, "Example HTML"
      end

      describe "when true" do
        let(:strict_mode) { true }

        it "raises a validation error" do
          assert_raises(Slimmer::Skin::TemplateParseError) { subject }
        end
      end

      describe "when nil in development" do
        let(:strict_mode) { nil }
        let(:rack_env) { "development" }

        it "raises a validation error" do
          assert_raises(Slimmer::Skin::TemplateParseError) { subject }
        end
      end

      describe "when nil in test" do
        let(:strict_mode) { nil }
        let(:rack_env) { "test" }

        it "raises a validation error" do
          assert_raises(Slimmer::Skin::TemplateParseError) { subject }
        end
      end

      describe "when nil in production" do
        let(:strict_mode) { nil }

        it "parses correctly" do
          assert_kind_of Nokogiri::HTML::Document, subject
        end
      end

      describe "when false in development" do
        let(:strict_mode) { false }
        let(:rack_env) { "development" }

        it "parses correctly" do
          assert_kind_of Nokogiri::HTML::Document, subject
        end
      end

      describe "when false in production" do
        let(:strict_mode) { false }

        it "parses correctly" do
          assert_kind_of Nokogiri::HTML::Document, subject
        end
      end
    end
  end

  describe "parsing artefact from header" do
    before do
      @skin = Slimmer::Skin.new cache: Slimmer::Cache.instance
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
