# -*- encoding: utf-8 -*-

require "rubygems"
require "rake/gempackagetask"
require "rake/rdoctask"
require "rake/testtask"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new :spec

namespace :test do
  desc "Run tests with all available Ruby interpreters"

  task :versions do |t|
    # Kind of re-entrant, but it shouldn't matter too much
    rubies = `rvm list strings`.split("\n")
    system "rvm #{rubies.join(",")} rake spec"
  end
end

task :default => ["spec"]

spec = Gem::Specification.load('slimmer.gemspec')

Rake::GemPackageTask.new(spec) do
end

Rake::RDocTask.new do |rd|
  rd.rdoc_files.include("lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
end

