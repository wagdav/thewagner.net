#! /usr/bin/env nix-shell
#! nix-shell ../shell.nix -i bash

PORT=8000

pelican \
  --output output \
  --settings pelicanconf.py \
  --port $PORT \
  --listen \
  --autoreload \
  content
