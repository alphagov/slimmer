# -*- encoding: utf-8 -*-

require "rubygems"
require "rubygems/package_task"
require "rdoc/task"
require 'rake/testtask'

spec = Gem::Specification.load('slimmer.gemspec')

Gem::PackageTask.new(spec) do
end

RDoc::Task.new do |rd|
  rd.rdoc_files.include("lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
end

Rake::TestTask.new("test") do |t|
  t.ruby_opts << "-rubygems"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end

task :default => :test