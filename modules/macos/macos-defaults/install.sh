#!/bin/bash
# modules/macos/macos-defaults/install.sh — macOS 시스템 환경설정
# macOS Tahoe 26 호환 (Apple Silicon)

# ── System Settings 닫기 ──
osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true

###############################################################################
# General UI/UX
###############################################################################

info "General UI/UX..."
sudo pmset -a standbydelay 86400

# Set sidebar icon size to medium
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2
# Increase window resize speed for Cocoa applications
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true
# Disable the "Are you sure you want to open this application?" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false
# Display ASCII control characters using caret notation
defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true
# Disable Resume system-wide
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false
# Disable automatic termination of inactive apps
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true
# Disable automatic capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
# Disable smart dashes
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
# Disable automatic period substitution
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
# Disable smart quotes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
# Reveal IP address in login window
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo -string HostName

###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input
###############################################################################

info "Trackpad & keyboard..."
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 1
# Trackpad click threshold
defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 0
# Tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -int 1
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write com.apple.AppleMultitouchTrackpad Clicking -int 1
# 3-finger drag
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
# 3-finger find
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -int 2
# Trackpad click sound
defaults write com.apple.AppleMultitouchTrackpad ActuationStrength -int 1
# Natural scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true
# Full keyboard access for all controls
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
# Disable press-and-hold for keys (enable key repeat)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
# Fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -float 1
# Short initial key repeat delay
defaults write NSGlobalDomain InitialKeyRepeat -int 15

###############################################################################
# Screen
###############################################################################

info "Screen..."
# Save screenshots to the desktop
defaults write com.apple.screencapture location -string "$HOME/Desktop"
# Save screenshots in PNG format
defaults write com.apple.screencapture type -string png
# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

###############################################################################
# Finder
###############################################################################

info "Finder..."
# Allow quitting via Cmd + Q
defaults write com.apple.finder QuitMenuItem -bool true
# Disable window animations
defaults write com.apple.finder DisableAllAnimations -bool true
# Set Desktop as default location
defaults write com.apple.finder NewWindowTarget -string PfDe
defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/Desktop/"
# Show icons on desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true
# Show path bar
defaults write com.apple.finder ShowPathbar -bool true
# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true
# Search current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string SCcf
# Disable warning when changing file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
# Enable spring loading for directories
defaults write NSGlobalDomain com.apple.springing.enabled -bool true
# Remove spring loading delay
defaults write NSGlobalDomain com.apple.springing.delay -float 0
# Avoid .DS_Store on network and USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
# Disable disk image verification
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true
# Auto-open Finder window when volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true
# Use list view by default
defaults write com.apple.finder FXPreferredViewStyle -string Nlsv
# Disable warning before emptying Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false
# Enable AirDrop over Ethernet
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

# Expand Finder File Info panes
defaults write com.apple.finder FXInfoPanesExpanded -dict \
    General -bool true \
    OpenWith -bool true \
    Privileges -bool true

# Finder icon view settings
local plist="$HOME/Library/Preferences/com.apple.finder.plist"
for view in DesktopViewSettings FK_StandardViewSettings StandardViewSettings; do
    /usr/libexec/PlistBuddy -c "Set :${view}:IconViewSettings:showItemInfo true" "$plist" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Set :${view}:IconViewSettings:labelOnBottom true" "$plist" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Set :${view}:IconViewSettings:arrangeBy name" "$plist" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Set :${view}:IconViewSettings:gridSpacing 33" "$plist" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Set :${view}:IconViewSettings:textSize 12" "$plist" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Set :${view}:IconViewSettings:iconSize 52" "$plist" 2>/dev/null || true
done

# Show ~/Library folder
chflags nohidden "$HOME/Library"

###############################################################################
# Dock
###############################################################################

info "Dock..."
# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true
# Dock orientation
defaults write com.apple.dock orientation -string bottom
# Enable highlight hover effect for stack grid view
defaults write com.apple.dock mouse-over-hilite-stack -bool true
# Set icon size to 36 pixels
defaults write com.apple.dock tilesize -int 36
# Scale minimize effect
defaults write com.apple.dock mineffect -string scale
# Minimize windows into application icon
defaults write com.apple.dock minimize-to-application -bool true
# Enable spring loading for all Dock items
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true
# Show indicator lights for open applications
defaults write com.apple.dock show-process-indicators -bool true
# Don't animate opening applications
defaults write com.apple.dock launchanim -bool false
# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1
# Don't group windows by application in Mission Control
defaults write com.apple.dock expose-group-by-app -bool false
# Disable recent apps
defaults write com.apple.dock show-recents -bool false
# Don't automatically rearrange Spaces
defaults write com.apple.dock mru-spaces -bool false
# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0
# Remove the animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0
# Make hidden application icons translucent
defaults write com.apple.dock showhidden -bool true
# Hot corners - all disabled
defaults write com.apple.dock wvous-tl-corner -int 0
defaults write com.apple.dock wvous-tl-modifier -int 0
defaults write com.apple.dock wvous-tr-corner -int 0
defaults write com.apple.dock wvous-tr-modifier -int 0
defaults write com.apple.dock wvous-br-corner -int 0
defaults write com.apple.dock wvous-br-modifier -int 0

###############################################################################
# Time Machine
###############################################################################

defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

###############################################################################
# Activity Monitor
###############################################################################

info "Activity Monitor..."
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true
defaults write com.apple.ActivityMonitor IconType -int 5
defaults write com.apple.ActivityMonitor ShowCategory -int 0
defaults write com.apple.ActivityMonitor SortColumn -string CPUUsage
defaults write com.apple.ActivityMonitor SortDirection -int 0

###############################################################################
# TextEdit & Disk Utility
###############################################################################

info "TextEdit & Disk Utility..."
# Use plain text mode for new TextEdit documents
defaults write com.apple.TextEdit RichText -int 0
# Open and save files as UTF-8 in TextEdit
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4
# Enable debug menu in Disk Utility
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
defaults write com.apple.DiskUtility advanced-image-options -bool true
# Auto-play videos in QuickTime
defaults write com.apple.QuickTimePlayerX MGPlayMovieOnOpen -bool true

###############################################################################
# Mac App Store & Software Update
###############################################################################

info "Software Update..."
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1
defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1
defaults write com.apple.commerce AutoUpdate -bool true

###############################################################################
# Photos
###############################################################################

defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

###############################################################################
# Messages
###############################################################################

info "Messages..."
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "continuousSpellCheckingEnabled" -bool false

###############################################################################
# Keyboard Shortcuts
###############################################################################

info "Keyboard shortcuts..."

# Mission Control: Spaces Left (Control+Left)
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 79 "
  <dict>
    <key>enabled</key><true/>
    <key>value</key><dict>
      <key>type</key><string>standard</string>
      <key>parameters</key>
      <array>
        <integer>65535</integer>
        <integer>123</integer>
        <integer>262144</integer>
      </array>
    </dict>
  </dict>
"

# Mission Control: Spaces Right (Control+Right)
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 81 "
  <dict>
    <key>enabled</key><true/>
    <key>value</key><dict>
      <key>type</key><string>standard</string>
      <key>parameters</key>
      <array>
        <integer>65535</integer>
        <integer>124</integer>
        <integer>262144</integer>
      </array>
    </dict>
  </dict>
"

# Spotlight: Show search field (Cmd+Shift+Space)
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "
  <dict>
    <key>enabled</key><true/>
    <key>value</key><dict>
      <key>type</key><string>standard</string>
      <key>parameters</key>
      <array>
        <integer>65535</integer>
        <integer>49</integer>
        <integer>1179648</integer>
      </array>
    </dict>
  </dict>
"

# Select previous input source (Cmd+Space)
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 60 "
  <dict>
    <key>enabled</key><true/>
    <key>value</key><dict>
      <key>type</key><string>standard</string>
      <key>parameters</key>
      <array>
        <integer>32</integer>
        <integer>49</integer>
        <integer>1048576</integer>
      </array>
    </dict>
  </dict>
"

# Select next input source (Cmd+Option+Space)
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 61 "
  <dict>
    <key>enabled</key><true/>
    <key>value</key><dict>
      <key>type</key><string>standard</string>
      <key>parameters</key>
      <array>
        <integer>32</integer>
        <integer>49</integer>
        <integer>1572864</integer>
      </array>
    </dict>
  </dict>
"

###############################################################################
# Scroll Reverser
###############################################################################

defaults write com.pilotmoon.scroll-reverser ReverseTrackpad -bool false
defaults write com.pilotmoon.scroll-reverser ReverseTablet -bool false
defaults write com.pilotmoon.scroll-reverser SUEnableAutomaticChecks -bool true

###############################################################################
# Kill affected applications
###############################################################################

info "Restarting affected applications..."
for app in "Activity Monitor" Calendar cfprefsd Contacts Dock Finder \
    Mail Messages Photos SystemUIServer; do
    killall "$app" 2>/dev/null || true
done

success "macOS defaults"
