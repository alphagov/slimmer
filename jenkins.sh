#!/bin/bash -x
set -e

git clean -fdx

# Try to merge master into the current branch, and abort if it doesn't exit
# cleanly (ie there are conflicts). This will be a noop if the current branch
# is master.
git merge --no-commit origin/master || git merge --abort

function test() {
  local rails_version="$1"
  local ruby_version="$2"

  export BUNDLE_GEMFILE="./gemfiles/Gemfile.rails-${rails_version}"
  export RBENV_VERSION="${ruby_version}"

  bundle install --path "${HOME}/bundles/${JOB_NAME}"
  bundle exec rake test --trace

  unset RBENV_VERSION
}

test 5.0.x 2.3
test 5.0.x 2.2

test 4.2.x 2.3
test 4.2.x 2.2
test 4.2.x 2.1
test 4.2.x 1.9.3

test 4.1.x 2.3
test 4.1.x 2.2
test 4.1.x 2.1
test 4.1.x 1.9.3

test 3.2.x 2.3
test 3.2.x 2.2
test 3.2.x 2.1
test 3.2.x 1.9.3

bundle install --path "${HOME}/bundles/${JOB_NAME}"
bundle exec govuk-lint-ruby --diff --cached --format clang bin lib test

if [[ -n "$PUBLISH_GEM" ]]; then
  bundle exec rake publish_gem --trace
fi
