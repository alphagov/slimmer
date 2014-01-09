require_relative 'test_helper'

describe 'CHANGELOG' do

  it "should have an entry for the current version" do
    changelog_contents = File.read(File.expand_path("../../CHANGELOG.md", __FILE__))

    assert_match /^#+\s*#{Regexp.escape(Slimmer::VERSION)}/, changelog_contents, "No entry for #{Slimmer::VERSION} found in CHANGELOG.md"
  end
end
