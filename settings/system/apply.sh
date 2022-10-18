#!/bin/bash

DIR_SETTINGS_SYSTEM=$DOTHOME/settings/system

pushd $DIR_SETTINGS_SYSTEM >/dev/null 2>&1
for file in .*; do
  if [[ $file = "." || $file = ".." || $file = "" ]]; then
    continue
  fi
  sh $file
done
popd >/dev/null 2>&1
