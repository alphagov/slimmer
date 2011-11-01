# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = "slimmer"
  s.version     = "0.8.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ben Griffiths", "James Stewart"]
  s.email       = ["bengriffiths@gmail.com", "james.stewart@digital.cabinet-office.gov.uk"]
  s.homepage    = "http://github.com/alphagov/slimmer"
  s.summary     = %q{Thinner than the skinner}
  s.description = %q{Rack middleware for skinning pages using a specific template}

  s.rubyforge_project = "slimmer"

  s.add_dependency('nokogiri')

  s.files         = Dir[
    'lib/**/*',
    'Rakefile'
  ]
  s.test_files    = Dir['test/**/*']
  s.executables   = []
  s.require_paths = ["lib"]
end
