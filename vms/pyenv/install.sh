#!/bin/bash
#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

function command_exists() {
  hash "$1" &>/dev/null
}

function configuration() {
  echo 'if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi' >> ~/.zshrc
  echo 'source $(brew --prefix autoenv)/activate.sh' >> ~/.zshrc
}

# Check for pyenv
if ! command_exists pyenv; then
  echo "  Installing pyenv for you."

  brew install pyenv pyenv-virtualenv autoenv
  configuration
fi

# Check for n installed
pyenv -v

# install 3.7
CC=`which gcc-11` arch -x86_64 pyenv install 3.7.14
