# -*- encoding: utf-8 -*-

require "rubygems"
require "rubygems/package_task"
require "rdoc/task"

spec = Gem::Specification.load('slimmer.gemspec')

Gem::PackageTask.new(spec) do
end

RDoc::Task.new do |rd|
  rd.rdoc_files.include("lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
end

