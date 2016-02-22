require_relative "test_helper"

describe Slimmer::ComponentResolver do
  describe "find_templates" do
    before do
      @resolver = Slimmer::ComponentResolver.new
    end

    it "should return nothing if the prefix doesn't match 'govuk_component'" do
      assert_equal [], @resolver.find_templates('name', 'prefix', false, {}, false)
    end

    it "should request a valid template from the server" do
      assert_valid_template_requested('name', 'name.raw.html.erb')
    end

    it "should request a valid template from the server when a raw template is requested" do
      assert_valid_template_requested('name.raw', 'name.raw.html.erb')
    end

    it "should request a valid template from the server when the full template filename is requested" do
      assert_valid_template_requested('name.raw.html.erb', 'name.raw.html.erb')
    end

    it "should return a known template in test mode" do
      @resolver.expects(:test?).returns(true)

      templates = @resolver.find_templates('name', 'govuk_component', false, {}, false)
      assert_match /<test-govuk-component data-template="govuk_component-name">/, templates.first.args[0]
    end
  end

  def assert_valid_template_requested(requested, expected)
    expected_url = "http://static.dev.gov.uk/templates/govuk_component/#{expected}"
    stub_request(:get, expected_url).to_return body: "<foo />"

    templates = @resolver.find_templates(requested, 'govuk_component', false, {}, false)
    assert_requested :get, expected_url
    assert_equal '<foo />', templates.first.args[0]
  end
end
