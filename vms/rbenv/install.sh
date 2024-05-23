#!/bin/bash

function command_exists() {
  hash "$1" &>/dev/null
}

function configuration() {
  rbenv init &>/dev/null
  
  echo '# rbenv setup' >> ~/.zshrc
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc
  echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc
  echo '' >> ~/.zshrc
}

# Check for fnm
if ! command_exists rbenv; then
  echo "  Installing rbenv for you."

  brew install rbenv ruby-build
fi

configuration

rbenv -h
