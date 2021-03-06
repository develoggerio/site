#!/bin/bash

# Enable error reporting to the console.
set -e

# Install bundles if needed
bundle check || bundle install

# NPM install if needed.
. $HOME/.nvm/nvm.sh && nvm install 6.1 && nvm use 6.1
npm install

# Build the site.
gulp

# Checkout master and remove everything
git clone https://${GH_TOKEN}@github.com/develoggerio/site.git ../develoggerio.github.io.master
cd ../develoggerio.github.io.master
git checkout master
rm -rf *

# Copy generated HTML site from source branch in original repo.
# Now the master branch will contain only the contents of the _site directory.
cp -R ../develoggerio.github.io/_site/* .

# Make sure we have the updated .travis.yml file so tests won't run on master.
cp ../develoggerio.github.io/.travis.yml .
git config user.email ${GH_EMAIL}
git config user.name "develogger-bot"

# Commit and push generated content to master branch.
git status
git add -A .
git status
git commit -a -m "Travis #$TRAVIS_BUILD_NUMBER"
git push --quiet origin master > /dev/null 2>&1

# Purge the CloudFlare cache.
curl -X DELETE "https://api.cloudflare.com/client/v4/zones/${CF_ZONE}/purge_cache" \
  -H "X-Auth-Email: ${CF_EMAIL}" \
  -H "X-Auth-Key: ${CF_KEY}" \
  -H "Content-Type: application/json" \
  --data '{"purge_everything":true}'
