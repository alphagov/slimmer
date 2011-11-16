# -*- encoding: utf-8 -*-

require 'slimmer/version'
Gem::Specification.new do |s|
  s.name        = "slimmer"
  s.version     = Slimmer::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ben Griffiths", "James Stewart"]
  s.email       = ["bengriffiths@gmail.com", "james.stewart@digital.cabinet-office.gov.uk"]
  s.homepage    = "http://github.com/alphagov/slimmer"
  s.summary     = %q{Thinner than the skinner}
  s.description = %q{Rack middleware for skinning pages using a specific template}

  s.rubyforge_project = "slimmer"

  s.add_dependency('nokogiri')

  s.test_files    = Dir['test/**/*']
  s.add_development_dependency 'rake', '~> 0.9.0'
  s.add_development_dependency 'rack-test'

  s.files         = Dir[
    'README.md',
    'CHANGELOG.md',
    'lib/**/*',
    'Rakefile'
  ]
  s.executables   = []
  s.require_paths = ["lib"]
end
