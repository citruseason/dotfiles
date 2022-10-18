#!/bin/bash

export DIR_SETTINGS_GIT=$DOTHOME/settings/git

pushd $DIR_SETTINGS_GIT >/dev/null 2>&1
for file in .*; do
  if [[ $file = "." || $file = ".." || $file = "" ]]; then
    continue
  fi
  cp $DIR_SETTINGS_GIT/$file $DOTCDIR
done
popd >/dev/null 2>&1
