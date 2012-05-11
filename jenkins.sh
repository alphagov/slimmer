#!/bin/bash -x
set -e
rm -f Gemfile.lock
bundle install --path "${HOME}/bundles/${JOB_NAME}"
bundle exec rake test --trace
bundle exec rake publish_gem
