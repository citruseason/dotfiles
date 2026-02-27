#!/bin/bash
# config/macos.sh — macOS 전용 변수

FONT_DIR="$HOME/Library/Fonts"

DOCK_APPS=(
    /Applications/Safari.app
    "/Applications/Google Chrome.app"
    /System/Applications/Calendar.app
    /System/Applications/Notes.app
    /Applications/Notion.app
    /Applications/Slack.app
    /Applications/Ghostty.app
)

# dock_folders: "path|display|sort" 형식
DOCK_FOLDERS=(
    "/Applications|stack|name"
    "$HOME/Downloads|stack|dateadded"
    "$HOME/Documents|stack|name"
    "$HOME/Pictures|stack|name"
)
