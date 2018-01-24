#!/usr/bin/env bash

###############################################################################
# "iTerm2 settings"
###############################################################################
mkdir -p $DOTCDIR/plists && cp $DIR_SETTINGS_APPS/plists/com.googlecode.iterm2.plist $DOTCDIR/plists

# Specify the preferences directory
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$DOTCDIR/plists"
# Tell iTerm2 to use the custom preferences in the directory
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

echo "Success! iTerm2 is set."