#!/bin/bash -x
set -e

# Try to merge master into the current branch, and abort if it doesn't exit
# cleanly (ie there are conflicts). This will be a noop if the current branch
# is master.
git merge --no-commit origin/master || git merge --abort

rm -f Gemfile.lock
bundle install --path "${HOME}/bundles/${JOB_NAME}"
bundle exec rake test --trace

if [[ -n "$PUBLISH_GEM" ]]; then
  bundle exec rake publish_gem --trace
fi
