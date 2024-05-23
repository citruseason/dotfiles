#!/bin/bash

function command_exists() {
  hash "$1" &>/dev/null
}

function configuration() {
  rbenv init
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc
  echo 'eval "$(rbenv init -)"' >> ~/.zshrc
}

# Check for fnm
if ! command_exists rbenv; then
  echo "  Installing rbenv for you."

  brew install rbenv ruby-build
  configuration
fi

rbenv -h
