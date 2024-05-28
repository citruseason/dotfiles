#!/bin/bash

export DOTHOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTCDIR="$HOME/.dotfiles.d"
export DOTCBAK="$HOME/.dotfiles.d.bak"
export DOT_EXCUTE_TIME=$(date +'%Y-%m-%dT%H:%M:%S')

# error handle
set -e

source $DOTHOME/libs/os.sh

# Include Adam Eivy's library helpers.
source $DOTHOME/libs/print.sh

source $DOTHOME/libs/permission.sh

function clear_environment() {
  unset sudoPW
  unset SUDO_ASKPASS
}

#############################################
# Introduction
#############################################

awesome_header

#############################################
# permission
#############################################

clear_environment

echo ""
read -s -p "Enter Password for sudo: " sudopassword
export sudoPW=$sudopassword
export SUDO_ASKPASS=$DOTHOME/libs/sudo-askpass.sh

#############################################
# Install packages
#############################################
bot "Install packages"

running "xcode command line tools install"
sh "$DOTHOME/packages/xcode-command-line-tools/install.sh"
ok

running "homebrew packages install (common)"
sh $DOTHOME/packages/homebrew/install.sh common
ok

running "homebrew packages install (private)"
sh $DOTHOME/packages/homebrew/install.sh private
ok

running "add homebrew path"
export PATH=/opt/homebrew/bin:/opt/homebrew/sbin:$PATH
ok

action "fonts install"
sh "$DOTHOME/packages/fonts/install.sh"
ok

#############################################
# Setup settings
#############################################
bot "Setup settings"

action "set data directory"

mkdir -p $DOTCBAK/$DOT_EXCUTE_TIME
if [[ -d "$DOTCDIR" ]]; then
  mv $DOTCDIR $DOTCBAK/$DOT_EXCUTE_TIME
else
  cp $HOME/.bashrc $DOTCBAK/$DOT_EXCUTE_TIME/ &>/dev/null || :
  cp $HOME/.zshrc $DOTCBAK/$DOT_EXCUTE_TIME/ &>/dev/null || :
  cp $HOME/.aliases $DOTCBAK/$DOT_EXCUTE_TIME/ &>/dev/null || :
  cp $HOME/.gitconfig $DOTCBAK/$DOT_EXCUTE_TIME/ &>/dev/null || :
  cp $HOME/.gitconfig-company $DOTCBAK/$DOT_EXCUTE_TIME/ &>/dev/null || :
  cp $HOME/.gitconfig-personal $DOTCBAK/$DOT_EXCUTE_TIME/ &>/dev/null || :
  cp $HOME/.gitignore $DOTCBAK/$DOT_EXCUTE_TIME/ &>/dev/null || :
fi
mkdir -p $DOTCDIR

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
pushd $DOTCDIR >/dev/null 2>&1
for name in $(ls -a); do
  if [[ $name = "." || $name = ".." || $name = "" || $name = "plists" || $name = "karabiner" ]]; then
    continue
  fi

  if [ -f "$HOME/$name" ]; then
    unlink $HOME/$name
  fi

  ln -s $DOTCDIR/$name $HOME/$name
done
popd >/dev/null 2>&1
ok

#############################################
# Global install dotfiles command
#############################################
bot "dotfiles command install"

action "set permission"
chmod -R +wx ./bin
ok

action "set path environment (bash)"
echo '' >> $HOME/.bashrc
sed -i '' "s#export DOTHOME=$DOTHOME##g" $HOME/.bashrc &>/dev/null || :
sed -i '' "s#export DOTCDIR=$DOTCDIR##g" $HOME/.bashrc &>/dev/null || :
sed -i '' "s#export DOTCBAK=$DOTCBAK##g" $HOME/.bashrc &>/dev/null || :
sed -i '' "s#export DOT_EXCUTE_TIME=$DOT_EXCUTE_TIME##g" $HOME/.bashrc &>/dev/null || :
echo "export DOTHOME="$DOTHOME"" >> $HOME/.bashrc
echo "export DOTCDIR="$DOTCDIR"" >> $HOME/.bashrc
echo "export DOTCBAK="$DOTCBAK"" >> $HOME/.bashrc
echo "export DOT_EXCUTE_TIME="$DOT_EXCUTE_TIME"" >> $HOME/.bashrc
echo '' >> $HOME/.bashrc
ok

action "set path environment (zsh)"
echo '' >> $HOME/.zshrc
echo "export DOTHOME="$DOTHOME"" >> $HOME/.zshrc
echo "export DOTCDIR="$DOTCDIR"" >> $HOME/.zshrc
echo "export DOTCBAK="$DOTCBAK"" >> $HOME/.zshrc
echo "export DOT_EXCUTE_TIME="$DOT_EXCUTE_TIME"" >> $HOME/.zshrc
echo '' >> $HOME/.zshrc
ok

action "apply"
echo 'export PATH="$DOTHOME/bin:$PATH"' >> $HOME/.zshrc
ok

#############################################
# Install Version Managers
#############################################
bot "Install vms"

running "fnm install"
sh "$DOTHOME/vms/fnm/install.sh"
ok

running "jenv install"
sh "$DOTHOME/vms/jenv/install.sh"
ok

running "pyenv install"
sh "$DOTHOME/vms/pyenv/install.sh"
ok

running "rbenv install"
sh "$DOTHOME/vms/rbenv/install.sh"
ok

clear_environment

echo ""
echo ""
echo "Done! Dotfiles is installed."
echo "Please 'Reboot' your mac !!"
