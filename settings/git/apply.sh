#!/usr/bin/env bash

export DIR_SETTINGS_GIT=$DOTHOME/settings/git

pushd $DIR_SETTINGS_GIT > /dev/null 2>&1
for file in .*; do
  if [[ $file = "." || $file = ".." || $file = "" ]]; then
    continue
  fi

  unlink ~/$file > /dev/null 2>&1
  ln -s "$DIR_SETTINGS_GIT/$file" ~
done
popd > /dev/null 2>&1

echo "Done! Git is set."