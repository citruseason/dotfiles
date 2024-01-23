#!/bin/bash

export DOTHOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export DOTCDIR="$HOME/.dotfiles.d"
export DOTCBAK="$HOME/.dotfiles.d.bak"

# error handle
set -e

source $DOTHOME/libs/os.sh

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

action "zsh install"
sudo apt-get install zsh
ok

action "antigen install"
mkdir -p /usr/local/share/antigen/
mkdir -p $HOME/tmp/antigen/
curl -L git.io/antigen > $HOME/tmp/antigen.zsh
sudo mv $HOME/tmp/antigen.zsh /usr/local/share/antigen/antigen.zsh
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

action "set git settings"
bash "$DOTHOME/settings/git/apply.sh"
ok

action "set zsh settings"
bash "$DOTHOME/settings/zsh/apply.sh"
ok

action "clear cache"
bash "$DOTHOME/bin/dotfiles" clean
ok

#############################################
# Link
#############################################
bot "Link settings"

action "linking"
pushd $DOTCDIR > /dev/null 2>&1
for name in $(ls -a); do
  if [[ $name = "." || $name = ".." || $name = "" || $name = "plists" ]]; then
    continue
  fi

  if [ -f "$HOME/$name" ]; then
    unlink $HOME/$name
  fi

  ln -s $DOTCDIR/$name $HOME/$name
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
if [ -f /usr/local/bin/dotfiles ]; then
  sudo unlink /usr/local/bin/dotfiles > /dev/null
fi
sudo ln -s $DOTHOME/bin/dotfiles /usr/local/bin/dotfiles
ok


#############################################
# Install Version Managers
#############################################
bot "Install vms"

running "nvm (node version manager) install"
zsh "$DOTHOME/vms/nvm/install.sh"
ok


echo "\n\nDone! Dotfiles is installed."
