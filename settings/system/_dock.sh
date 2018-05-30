#!/usr/bin/env bash

dockutil --no-restart --remove all

# Browser
dockutil --no-restart --add "/Applications/Google Chrome.app"

# Life Management
dockutil --no-restart --add "/Applications/Calendar.app"
dockutil --no-restart --add "/Applications/Notes.app"

# Personal Messanger
dockutil --no-restart --add "/Applications/Messages.app"
dockutil --no-restart --add "/Applications/KakaoTalk.app"

# Team Messanger
dockutil --no-restart --add "/Applications/Slack.app"

# Collaboratively Tool
dockutil --no-restart --add "/Applications/Trello.app"

# Development Environment
dockutil --no-restart --add "/Applications/iTerm.app"
dockutil --no-restart --add "/Applications/Visual Studio Code.app"
dockutil --no-restart --add "/Applications/TablePlus.app"
dockutil --no-restart --add "/Applications/Postman.app"

# Folders
dockutil --no-restart --add "/Applications" --display stack --sort name --before Trash
dockutil --no-restart --add "$HOME/Downloads" --display stack --sort dateadded --before Trash
dockutil --no-restart --add "$HOME/Documents" --display stack --sort name --before Trash

killall Dock

echo "Success! Dock is set."
