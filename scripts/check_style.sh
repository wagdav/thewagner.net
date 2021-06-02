#!/bin/sh
nix shell nixpkgs#pandoc -c pandoc "$1" --to plain | \
nix shell nixpkgs#diction -c diction --suggest --beginner
