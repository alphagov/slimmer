require_relative "test_helper"

describe Slimmer::I18nBackend do
  describe "#available_locales" do
    it "returns available locales" do
      stub_request(:get, "http://static.dev.gov.uk/templates/locales").
        to_return(status: 200, body: %w[tk ka ro].to_json)

      backend = Slimmer::I18nBackend.new
      locales = backend.available_locales

      assert_equal(%i[tk ka ro], locales)
    end
  end
end
