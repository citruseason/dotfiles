#!/bin/bash

function command_exists() {
  hash "$1" &>/dev/null
}

function configuration() {
  echo 'export PATH="$HOME/.jenv/bin:$PATH"' >> ~/.zshrc
  echo 'eval "$(jenv init -)"' >> ~/.zshrc
}

# Check for fnm
if ! command_exists jenv; then
  echo "  Installing jenv for you."

  brew install jenv
  configuration
fi

jenv -h
