#!/usr/bin/env bash

###############################################################################
# "Apple Terminal settings"
###############################################################################
# "Terminal.app settings Import"
defaults delete com.apple.Terminal.plist
rm -rf ~/Library/Preferences/com.apple.Terminal.plist
ln -sfv $DIR_SETTINGS_APPS/plists/com.apple.Terminal.plist ~/Library/Preferences/
