#! /usr/bin/env nix-shell
#! nix-shell -p ghp-import -i bash

set -eu

USER=wagdav
REPO=wagdav.github.com

if [ $# -eq 1 ]; then
    TOKEN=$1
    GITHUB=https://$USER:$TOKEN@github.com/$USER/$REPO
else
    GITHUB=git@github.com:$USER/$REPO
fi

GITHUB_PAGES_BRANCH=gh-pages
nix-build
ghp-import -m "Automatic update" -b $GITHUB_PAGES_BRANCH ./result
git push -f "$GITHUB" $GITHUB_PAGES_BRANCH:master
