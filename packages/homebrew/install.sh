#!/bin/bash
#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

UNAME_MACHINE="$(/usr/bin/uname -m)"
BREWFILE_PATH=$DOTHOME/packages/homebrew/common/Brewfile
BREWFILE_PRIVATE_PATH=$DOTHOME/packages/homebrew/private/Brewfile

# Check for Homebrew
if [[ ! $(which brew) ]]; then
  echo "  Installing Homebrew for you."

  if [[ "$DOT_OS_NAME" == "osx" ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ $DOT_ON_ARM == 1 ]]; then
      echo '# Set PATH, MANPATH, etc., for Homebrew.' >>$HOME/.zprofile
      echo 'eval $(/opt/homebrew/bin/brew shellenv)' >>$HOME/.zprofile
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  elif [[ "$DOT_OS_NAME" == "linux" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
  fi

fi

# Check for Homebrew update
brew update

# remove brewfile.lock.json
rm -rf ./**/Brewfile.lock.json

# =======================================
# Install
# =======================================

COMMAND_NAME=$1

cmd_help() {
  echo "Commands:"
  echo "   common           Install common apps"
  echo "   private          Install private apps"
}

cmd_common() {
  brew bundle --file=$BREWFILE_PATH
}

cmd_private() {
  brew bundle --file=$BREWFILE_PRIVATE_PATH
}

case $COMMAND_NAME in
*)
  shift
  cmd_${COMMAND_NAME} $@
  if [ $? = 127 ]; then
    echo -e "Error: '$COMMAND_NAME' is not a known command or has errors." >&2
    cmd_help
    exit 1
  fi
  ;;
esac
