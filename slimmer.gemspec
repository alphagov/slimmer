# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = "slimmer"
  s.version     = "0.7.9"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ben Griffiths"]
  s.email       = ["bengriffiths@gmail.com"]
  s.homepage    = "http://github.com/alphagov/slimmer"
  s.summary     = %q{Thinner than the skinner}
  s.description = %q{Thinner than the skinner}

  s.rubyforge_project = "slimmer"

  s.add_dependency('nokogiri',"~> 1.4.0")

  s.files         = Dir[
    'lib/**/*',
    'Rakefile'
  ]
  s.test_files    = Dir['test/**/*']
  s.executables   = []
  s.require_paths = ["lib"]
end
