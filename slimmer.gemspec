# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

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

  s.add_dependency 'nokogiri', '~> 1.5.0'
  s.add_dependency 'rack', '~> 1.3.5'
  s.add_dependency 'plek', '>= 0.1.8'
  s.add_dependency 'json'
  s.add_dependency 'null_logger'

  s.test_files    = Dir['test/**/*']
  s.add_development_dependency 'gds-api-adapters', '~> 0.0.33'
  s.add_development_dependency 'rake', '~> 0.9.2.2'
  s.add_development_dependency 'rack-test', '~> 0.6.1'
  s.add_development_dependency 'mocha', '~> 0.9.12'
  s.add_development_dependency 'webmock', '~> 1.7'
  s.add_development_dependency 'therubyracer'

  s.files         = Dir[
    'README.md',
    'CHANGELOG.md',
    'lib/**/*',
    'Rakefile'
  ]
  s.executables   = ["render_slimmer_error"]
  s.require_paths = ["lib"]
end
