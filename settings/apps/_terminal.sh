#!/usr/bin/env bash

###############################################################################
# "Apple Terminal settings"
###############################################################################
# "Terminal.app settings Import"
defaults delete com.apple.Terminal.plist
cp $DOTHOME/settings/apps/plists/com.apple.Terminal.plist ~/Library/Preferences/