require_relative "test_helper"

describe Slimmer::Skin do

  describe "loading templates" do
    it "should be able to load the template" do
      skin = Slimmer::Skin.new asset_host: "http://example.local/"
      expected_url = "http://example.local/templates/example.html.erb"
      stub_request(:get, expected_url).to_return :body => "<foo />"

      template = skin.template 'example'

      assert_requested :get, "http://example.local/templates/example.html.erb"
      assert_equal "<foo />", template
    end

    it "should cache the template" do
      skin = Slimmer::Skin.new asset_host: "http://example.local/", use_cache: true
      expected_url = "http://example.local/templates/example.html.erb"
      stub_request(:get, expected_url).to_return :body => "<foo />"

      first_access = skin.template 'example'
      second_access = skin.template 'example'

      assert_requested :get, "http://example.local/templates/example.html.erb", times: 1
      assert_same first_access, second_access
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
