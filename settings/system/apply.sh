#!/usr/bin/env bash

export DIR_SETTINGS_SYSTEM=$DOTHOME/settings/system

# pushd $DIR_SETTINGS_SYSTEM > /dev/null 2>&1
# for file in .*; do
#   if [[ $file = "." || $file = ".." || $file = "" ]]; then
#     continue
#   fi
#   ./$file
# done
# popd > /dev/null 2>&1

./_dock.sh
./_macos.sh

echo "Done! System is set."
