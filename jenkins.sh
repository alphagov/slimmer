#!/bin/bash -x
set -e

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

bundle install --path "${HOME}/bundles/${JOB_NAME}"
bundle exec rubocop --format clang
