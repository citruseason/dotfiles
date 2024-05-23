#!/bin/bash

function command_exists() {
  hash "$1" &>/dev/null
}

function configuration() {
  export PATH="$HOME/Library/Application Support/fnm:$PATH"
  eval "`fnm env --use-on-cd`"
  sed -i "s/fnm env/fnm env --use-on-cd/g" $HOME/.zshrc
}

# Check for fnm
if ! command_exists fnm; then
  echo "  Installing fnm for you."

  curl -fsSL https://fnm.vercel.app/install | bash
  configuration
fi

# Check for jenv installed
fnm --version

# 20.12.0 install
fnm install 20.12.0 &>/dev/null

# add package manager
npm install -g yarn pnpm

# corepack setup
corepack enable

# Check for node installed
node -v
