#!/usr/bin/env bash

export DIR_SETTINGS_APPS=$DOTHOME/settings/apps

echo "Installing settings apps"
for file in $(ls $DIR_SETTINGS_APPS/_*.sh); do
  if [[ $file = "." || $file = ".." || $file = "" || $file = " " ]]; then
    continue
  fi
  . $file
done