#!/bin/bash

source $DOTHOME/libs/permission.sh

DIR_SETTINGS_ZSH=$DOTHOME/settings/zsh

pushd $DIR_SETTINGS_ZSH >/dev/null 2>&1
for file in .*; do
  if [[ $file = "." || $file = ".." || $file = "" ]]; then
    continue
  fi
  cp $DIR_SETTINGS_ZSH/$file $DOTCDIR
done
popd >/dev/null 2>&1

# set default
exec_sudo sh -c "echo $(which zsh) >> /etc/shells" >/dev/null
exec_sudo chsh -s "$(which zsh)" "$(whoami)"
