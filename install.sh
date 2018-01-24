#!/usr/bin/env bash

export DOTHOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export DOTCDIR="$HOME/.dotfiles.d"
export DOTCBAK="$HOME/.dotfiles.d.bak"



#############################################
# Install packages
#############################################

# Install brew with packages & casks
. "$DOTHOME/packages/homebrew/install.sh"

# Install fonts
. "$DOTHOME/fonts/install.sh"

# Install SpaceVim
. "$DOTHOME/packages/vim/install.sh"


#############################################
# Install settings
#############################################

# Setup data directory
if [[ -d "$DOTCDIR" ]]; then
    rm -rf $DOTCBAK
    mv $DOTCDIR $DOTCBAK
fi
mkdir $DOTCDIR

# Setup macos defaults and add apps to dock
. "$DOTHOME/settings/macos/apply.sh"

# Setup git settings
. "$DOTHOME/settings/git/apply.sh"

# Setup vim settings
. "$DOTHOME/settings/vim/apply.sh"

# Setup zsh settings
. "$DOTHOME/settings/zsh/apply.sh"

# Setup apps settings
. "$DOTHOME/settings/apps/apply.sh"

# Clear cache
. "$DOTHOME/bin/dotfiles" clean


#############################################
# Link
#############################################

pushd $DOTCDIR > /dev/null 2>&1
for name in *; do
  if [[ $name = "." || $name = ".." || $name = "" || $name = "plists" ]]; then
    continue
  fi

  unlink $HOME/$name > /dev/null 2>&1
  ln -s $DOTCDIR/$name $HOME
done
popd > /dev/null 2>&1


#############################################
# Global install dotfiles command
#############################################

# Permission
chmod -R +wx ./bin

# Bash
sudo sh -c "echo export DOTHOME='$DOTHOME' >> /etc/profile" > /dev/null
sudo sh -c "echo export DOTHOME='$DOTCDIR' >> /etc/profile" > /dev/null
sudo sh -c "echo export DOTHOME='$DOTCBAK' >> /etc/profile" > /dev/null

# Zsh
sudo sh -c "echo export DOTHOME='$DOTHOME' >> /etc/zprofile" > /dev/null
sudo sh -c "echo export DOTHOME='$DOTCDIR' >> /etc/zprofile" > /dev/null
sudo sh -c "echo export DOTHOME='$DOTCBAK' >> /etc/zprofile" > /dev/null

# Apply
unlink /usr/local/bin/dotfiles
ln -s $DOTHOME/bin/dotfiles /usr/local/bin/dotfiles


echo "Done! Dotfiles is installed."
echo "Please 'Reboot' your mac !!"