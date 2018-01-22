#!/usr/bin/env bash

export DIR_SETTINGS_MACOS=$DOTHOME/settings/macos

echo "Installing settings macOS"
pushd $DIR_SETTINGS_MACOS > /dev/null 2>&1
for file in .*; do
  if [[ $file = "." || $file = ".." || $file = "" ]]; then
    continue
  fi
  ./$file
done
popd > /dev/null 2>&1