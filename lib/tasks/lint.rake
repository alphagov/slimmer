desc "Run rubocop with similar params to CI"
task :lint do
  sh "bundle exec rubocop --format clang bin lib test"
end
