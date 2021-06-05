#! /usr/bin/env nix-shell
#! nix-shell -p ghp-import -i bash

set -eu

SITE=$(nix-build --no-out-link -A packages.x86_64-linux.site)
ghp-import --message "Automatic update from https://github.com/wagdav/wagdav.github.com" "$SITE"
git push --force origin gh-pages:gh-pages
