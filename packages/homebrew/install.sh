#!/usr/bin/env bash
#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

# Check for Homebrew
if [[ ! $(which brew) ]]; then
  echo "  Installing Homebrew for you."

  if [[ MACOS ]]; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi

fi

# Check for Homebrew Cask
if [[ ! $(brew tap | grep cask) ]]; then
  echo "  Installing Homebrew for you."
  brew install caskroom/cask/brew-cask
fi

# Check for Homebrew update
brew update

# Install Brewfile
brew bundle --file=$DOTHOME/packages/homebrew/Brewfile

echo "Done! Homebrew is installed."