# -*- encoding: utf-8 -*-

require "bundler/gem_tasks"
require "rdoc/task"
require 'rake/testtask'

RDoc::Task.new do |rd|
  rd.rdoc_files.include("lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
end

Rake::TestTask.new("test") do |t|
  t.ruby_opts << "-rubygems"
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end

task :default => :test
