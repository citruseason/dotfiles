#!/usr/bin/env bash

DIR_SETTINGS_APPS=$DOTHOME/settings/apps
for file in $(ls $DIR_SETTINGS_APPS/_*.sh); do
  if [[ $file = "." || $file = ".." || $file = "" || $file = " " ]]; then
    continue
  fi
  sh $file
done