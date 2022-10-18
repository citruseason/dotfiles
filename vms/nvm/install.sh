#!/usr/bin/env bash
#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

function command_exists() {
  hash "$1" &>/dev/null
}

function configuration_nvm() {
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
}

# Check for NVM
if ! command_exists nvm; then
  echo "  Installing nvm for you."

  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
  configuration_nvm
fi

# Check for n installed
nvm --version

# LTS install
nvm install --lts

# Check for node installed
node -v
