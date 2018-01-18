#!/usr/bin/env bash

pushd . > /dev/null 2>&1
for file in _*.sh; do
  . "$DOTHOME/settings/apps/$file"
done
popd > /dev/null 2>&1
