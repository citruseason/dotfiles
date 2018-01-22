#!/usr/bin/env bash

###############################################################################
# "iTerm2 settings"
###############################################################################
# Specify the preferences directory
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$DIR_SETTINGS_APPS/plists"
# Tell iTerm2 to use the custom preferences in the directory
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

# Title bar color setting
echo -e "\033]6;1;bg;red;brightness;26\a"
echo -e "\033]6;1;bg;green;brightness;26\a"
echo -e "\033]6;1;bg;blue;brightness;26\a"


echo "Success! iTerm2 is set."