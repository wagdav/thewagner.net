#! /usr/bin/env nix-shell
#! nix-shell -p ghp-import -i bash

set -eu

USER=wagdav
REPO=wagdav.github.com

if [ -z ${DEPLOY_TOKEN+x} ]; then
    GITHUB=git@github.com:$USER/$REPO
else
    GITHUB=https://$USER:"$DEPLOY_TOKEN"@github.com/$USER/$REPO
fi

GITHUB_PAGES_BRANCH=gh-pages
nix-build
ghp-import -m "Automatic update" -b $GITHUB_PAGES_BRANCH ./result
git push -f "$GITHUB" $GITHUB_PAGES_BRANCH:master
