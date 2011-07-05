# -*- encoding: utf-8 -*-

require "rubygems"
require "rake/gempackagetask"

spec = Gem::Specification.load('slimmer.gemspec')

Rake::GemPackageTask.new(spec) do
end

Rake::RDocTask.new do |rd|
  rd.rdoc_files.include("lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
end

