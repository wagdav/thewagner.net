#! /usr/bin/env nix-shell
#! nix-shell ../shell.nix -i bash

set -eu

GITHUB_PAGES_BRANCH=gh-pages
nix-build -A publish
ghp-import -m "Automatic update" -b $GITHUB_PAGES_BRANCH ./result
git push -f git@github.com:wagdav/wagdav.github.com $GITHUB_PAGES_BRANCH:master
