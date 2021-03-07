#!/usr/bin/env bash
#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

UNAME_MACHINE="$(/usr/bin/uname -m)"
BREWFILE_PATH=$DOTHOME/packages/homebrew/Brewfile

# Check for Homebrew
if [[ ! $(which brew) ]]; then
  echo "  Installing Homebrew for you."

  if [[ "$DOT_OS_NAME" == "osx" ]]; then
	  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    if [[ $DOT_ON_ARM == 1 ]]; then
      sed -i -e '/^eval \$(\/opt\/homebrew\/bin\/brew shellenv)$/d' $HOME/.zprofile
      echo 'eval $(/opt/homebrew/bin/brew shellenv)' >> $HOME/.zprofile
    fi
  elif [[ "$DOT_OS_NAME" == "linux" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
  fi

fi

# Check for Homebrew update
brew update

# Install Brewfile
brew bundle --file=$BREWFILE_PATH
