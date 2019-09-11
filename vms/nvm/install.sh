#!/usr/bin/env bash
#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

# Check for NVM 
if [[ ! $(which nvm) ]]; then
  echo "  Installing NVM for you."

  if [[ MACOS ]]; then
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
	source ~/.zshrc
  fi

fi

# Check for NVM installed
nvm --version

# LTS install
nvm install --lts
