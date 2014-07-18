require_relative "test_helper"

describe Slimmer::ComponentResolver do
  describe "find_templates" do
    before do
      @resolver = Slimmer::ComponentResolver.new
    end

    it "should return nothing if the prefix doesn't match 'govuk_component'" do
      assert_equal [], @resolver.find_templates('name', 'prefix', false, {})
    end

    it "should request a valid template from the server" do
      expected_url = "http://static.dev.gov.uk/templates/govuk_component/name.raw.html.erb"
      stub_request(:get, expected_url).to_return :body => "<foo />"

      templates = @resolver.find_templates('name', 'govuk_component', false, {})
      assert_requested :get, expected_url
      assert_equal '<foo />', templates.first.args[0]
    end

    it "should return a known template in test mode" do
      @resolver.expects(:test?).returns(true)

      templates = @resolver.find_templates('name', 'govuk_component', false, {})
      assert_match /<div class="govuk_component-name">/, templates.first.args[0]
    end
  end
end
