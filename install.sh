#!/usr/bin/env bash

export DOTHOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export DOTCDIR="$HOME/.dotfiles.d"
export DOTCBAK="$HOME/.dotfiles.d.bak"

# error handle
set -e

# Include Adam Eivy's library helpers.
source $DOTHOME/libs/print.sh

#############################################
# Introduction
#############################################

awesome_header


#############################################
# Install packages
#############################################
bot "Install packages"

running "xcode command line tools install"
sh "$DOTHOME/packages/xcode-command-line-tools/install.sh"
ok

running "homebrew packages install"
sh "$DOTHOME/packages/homebrew/install.sh"
ok

action "fonts install"
sh "$DOTHOME/packages/fonts/install.sh"
ok


#############################################
# Setup settings
#############################################
bot "Setup settings"

action "set data directory"
if [[ -d "$DOTCDIR" ]]; then
    rm -rf $DOTCBAK
    mv $DOTCDIR $DOTCBAK
fi
mkdir $DOTCDIR
ok

action "set macos defaults and add apps to dock"
sh "$DOTHOME/settings/system/apply.sh"
ok

action "set git settings"
sh "$DOTHOME/settings/git/apply.sh"
ok

action "set zsh settings"
sh "$DOTHOME/settings/zsh/apply.sh"
ok

action "set apps settings"
sh "$DOTHOME/settings/apps/apply.sh"
ok

action "clear cache"
sh "$DOTHOME/bin/dotfiles" clean
ok

#############################################
# Link
#############################################

action "linking"
pushd $DOTCDIR > /dev/null 2>&1
for name in .*; do
  if [[ $name = "." || $name = ".." || $name = "" || $name = "plists" ]]; then
    continue
  fi

  unlink $HOME/$name > /dev/null 2>&1
  ln -s $DOTCDIR/$name $HOME
done
popd > /dev/null 2>&1
ok


#############################################
# Global install dotfiles command
#############################################
bot "dotfiles command install"

action "set permission"
chmod -R +wx ./bin
ok

action "set path environment (bash)"
sudo sh -c "echo export DOTHOME='$DOTHOME' >> /etc/profile" > /dev/null
sudo sh -c "echo export DOTCDIR='$DOTCDIR' >> /etc/profile" > /dev/null
sudo sh -c "echo export DOTCBAK='$DOTCBAK' >> /etc/profile" > /dev/null
ok

action "set path environment (zsh)"
sudo sh -c "echo export DOTHOME='$DOTHOME' >> /etc/zprofile" > /dev/null
sudo sh -c "echo export DOTCDIR='$DOTCDIR' >> /etc/zprofile" > /dev/null
sudo sh -c "echo export DOTCBAK='$DOTCBAK' >> /etc/zprofile" > /dev/null
ok

action "apply"
unlink /usr/local/bin/dotfiles
ln -s $DOTHOME/bin/dotfiles /usr/local/bin/dotfiles
ok

echo "\n\nDone! Dotfiles is installed."
echo "Please 'Reboot' your mac !!"
