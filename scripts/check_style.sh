#! /usr/bin/env nix-shell
#! nix-shell -p diction -p pandoc -i bash

pandoc "$1" --to plain | diction --suggest --beginner
