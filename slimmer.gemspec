lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require "slimmer/version"

Gem::Specification.new do |s|
  s.name        = "slimmer"
  s.version     = Slimmer::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["GOV.UK Dev"]
  s.email       = ["govuk-dev@digital.cabinet-office.gov.uk"]
  s.homepage    = "http://github.com/alphagov/slimmer"
  s.summary     = "Thinner than the skinner"
  s.description = "Rack middleware for skinning pages using a specific template"
  s.license = "MIT"

  s.required_ruby_version = ">= 3.2"

  s.add_dependency "json"
  s.add_dependency "nokogiri", "~> 1.7"
  s.add_dependency "null_logger"
  s.add_dependency "plek", ">= 1.1.0"
  s.add_dependency "rack", ">= 3.0"
  s.add_dependency "rest-client"

  s.add_development_dependency "climate_control", "~> 1.1"
  s.add_development_dependency "minitest", "~> 5.16"
  s.add_development_dependency "rack-test", "~> 2"
  s.add_development_dependency "rails", "~> 8"
  s.add_development_dependency "rake"
  s.add_development_dependency "rubocop-govuk", "5.1.20"
  s.add_development_dependency "webmock", "~> 3.8"

  s.files = Dir[
    "README.md",
    "CHANGELOG.md",
    "lib/**/*",
    "Rakefile",
  ]
  s.require_paths = %w[lib]
end
