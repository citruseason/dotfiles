#!/usr/bin/env bash

export DIR_SETTINGS_ZSH=$DOTHOME/settings/zsh

echo "Installing settings zsh"
pushd $DIR_SETTINGS_ZSH > /dev/null 2>&1
for file in .*; do
  if [[ $file = "." || $file = ".." || $file = "" ]]; then
    continue
  fi

  # unlink $HOME/$file > /dev/null 2>&1
  # ln -s "$DIR_SETTINGS_ZSH/$file" $HOME

  cp $DIR_SETTINGS_ZSH/$file $DOTCDIR
done
popd > /dev/null 2>&1

# set default
sudo sh -c "echo $(which zsh) >> /etc/shells" > /dev/null
chsh -s $(which zsh)

echo "Done! Zsh is set."