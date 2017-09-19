require_relative "test_helper"

describe Slimmer::ComponentResolver do
  describe "find_templates" do
    before do
      @resolver = Slimmer::ComponentResolver.new
    end

    it "should return nothing if the prefix doesn't match 'govuk_component'" do
      assert_equal [], @resolver.find_templates('name', 'prefix', false, {}, false)
    end

    it "should raise when template_body is called directly from ComponentResolver" do
      assert_raises NotImplementedError do
        @resolver.find_templates('name', 'govuk_component', false, {}, false)
      end
    end
  end
end
