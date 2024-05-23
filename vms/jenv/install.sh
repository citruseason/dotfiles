#!/bin/bash

function command_exists() {
  hash "$1" &>/dev/null
}

function configuration() {
  export PATH="$HOME/.jenv/bin:$PATH" &>/dev/null
  eval "$(jenv init -)" &>/dev/null

  echo '# jenv setup' >> ~/.zshrc
  echo 'export PATH="$HOME/.jenv/bin:$PATH"' >> ~/.zshrc
  echo 'eval "$(jenv init -)"' >> ~/.zshrc
  echo '' >> ~/.zshrc
}

# Check for fnm
if ! command_exists jenv; then
  echo "  Installing jenv for you."

  brew install jenv
fi

configuration

jenv -h
