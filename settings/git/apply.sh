#!/usr/bin/env bash

pushd . > /dev/null 2>&1
for file in .*; do
  unlink ~/$file > /dev/null 2>&1
  ls -s "$DOTHOME/settings/git/$file" ~
done
popd > /dev/null 2>&1