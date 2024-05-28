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
  export PATH="$HOME/.pyenv/bin:$PATH" &>/dev/null
  eval "$(pyenv init -)" &>/dev/null
  eval "$(pyenv virtualenv-init -)" &>/dev/null

  echo '# pyenv setup' >> ~/.zshrc
  echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.zshrc
  echo 'eval "$(pyenv init -)"' >> ~/.zshrc
  echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.zshrc
  echo '' >> ~/.zshrc
}

# Check for pyenv
if ! command_exists pyenv; then
  echo "  Installing pyenv for you."

  brew install pyenv pyenv-virtualenv
fi

configuration

# Check for n installed
pyenv -v

# install 3.7
# CC=`which gcc-11` arch -x86_64 pyenv install 3.7.14
