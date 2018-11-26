#!/usr/bin/env bash

###############################################################################
# "Apple Terminal settings"
###############################################################################
mkdir -p $DOTCDIR/plists && cp $DIR_SETTINGS_APPS/plists/com.apple.Terminal.plist $DOTCDIR/plists

# "Terminal.app settings Import"
defaults delete com.apple.Terminal.plist
rm -rf $HOME/Library/Preferences/com.apple.Terminal.plist
ln -sfv $DOTCDIR/plists/com.apple.Terminal.plist $HOME/Library/Preferences/