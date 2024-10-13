#!/bin/sh
nix shell nixpkgs#pandoc -c pandoc "$1" --to plain | \
nix shell nixpkgs#languagetool -c languagetool-commandline \
  --language en-US \
  -
