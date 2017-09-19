require_relative "test_helper"

describe Slimmer::LocalComponentResolver do
  describe "find_templates" do
    before do
      @resolver = Slimmer::LocalComponentResolver.new
    end

    it "should request a valid template" do
      assert_valid_template_requested('name', 'name.raw.html.erb')
    end

    it "should request a valid template when a raw template is requested" do
      assert_valid_template_requested('name.raw', 'name.raw.html.erb')
    end

    it "should request a valid template when the full template filename is requested" do
      assert_valid_template_requested('name.raw.html.erb', 'name.raw.html.erb')
    end
  end

  def assert_valid_template_requested(requested, expected)
    File.expects(:read).with("govuk_component/#{expected}").returns('<foo />')
    templates = @resolver.find_templates(requested, 'govuk_component', false, {}, false)
    assert_equal '<foo />', templates.first.args[0]
  end
end
