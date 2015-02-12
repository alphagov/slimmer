#!/bin/bash -x
set -e

git clean -fdx

# Try to merge master into the current branch, and abort if it doesn't exit
# cleanly (ie there are conflicts). This will be a noop if the current branch
# is master.
git merge --no-commit origin/master || git merge --abort

for version in 2.2 2.1 1.9.3; do
  export RBENV_VERSION=$version
  echo "Running tests under ruby $version"
  bundle install --path "${HOME}/bundles/${JOB_NAME}"
  bundle exec rake test --trace
done

unset RBENV_VERSION

if [[ -n "$PUBLISH_GEM" ]]; then
  bundle exec rake publish_gem --trace
fi
