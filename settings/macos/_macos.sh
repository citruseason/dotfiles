#!/usr/bin/env bash

###############################################################################
# "Trackpad, mouse, keyboard, Bluetooth accessories, and input"
###############################################################################

# "Trackpad: enable tap to click for this user and for the login screen"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1;

# "Enable tap to click. (Don't have to press down on the trackpad -- just tap it.)"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

# "Enable 3-finger drag. (Moving with 3 fingers in any window chrome moves the window.)"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

# "Enable 'natural' (Lion-style) scrolling"
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true;

# "Increase sound quality for Bluetooth headphones/headsets"
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40;

# "Enable press-and-hold for keys in favor of key repeat"
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false;

# "Set a blazingly fast keyboard repeat rate"
defaults write NSGlobalDomain KeyRepeat -int 1;
defaults write NSGlobalDomain InitialKeyRepeat -int 15;

# "Disable auto-correct"
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false;


###############################################################################
# "Configuring the Screen"
###############################################################################

# "Save screenshots to the desktop"
defaults write com.apple.screencapture location -string "${HOME}/Desktop";

# "Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)"
defaults write com.apple.screencapture type -string "png";

# "Disable shadow in screenshots"
defaults write com.apple.screencapture disable-shadow -bool true;

# "Enable subpixel font rendering on non-Apple LCDs"
defaults write NSGlobalDomain AppleFontSmoothing -int 2;

# "Require password immediately after sleep or screen saver begins"
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0;


###############################################################################
# "Finder Configs"
###############################################################################

# "Disable window animations and Get Info animations"
defaults write com.apple.finder DisableAllAnimations -bool true;

# "Show hidden files by default"
# defaults write com.apple.finder AppleShowAllFiles -bool true;

# "Show all filename extensions"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true;

# "Show status bar"
defaults write com.apple.finder ShowStatusBar -bool true;

# "Show path bar"
defaults write com.apple.finder ShowPathbar -bool true;

# "Allow text selection in Quick Look"
defaults write com.apple.finder QLEnableTextSelection -bool true;

# "Display full POSIX path as Finder window title"
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true;

# "When performing a search, search the current folder by default"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf";

# "Disable the warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false;

# "Enable spring loading for directories"
defaults write NSGlobalDomain com.apple.springing.enabled -bool true;

# "Remove the spring loading delay for directories"
defaults write NSGlobalDomain com.apple.springing.delay -float 0;

# "Avoid creating .DS_Store files on network volumes"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true;

# "Disable disk image verification"
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true;

# "Automatically open a new Finder window when a volume is mounted"
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true;

# "Use list view in all Finder windows by default"
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv";

# "Disable the warning before emptying the Trash"
defaults write com.apple.finder WarnOnEmptyTrash -bool false;

# "Empty Trash securely by default"
defaults write com.apple.finder EmptyTrashSecurely -bool true;

# "Enable AirDrop over Ethernet and on unsupported Macs # Lion"
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true;

# "Show the ~/Library folder"
chflags nohidden ~/Library;

# "Expand the following File Info panes: “General”, “Open with”, and “Sharing & Permissions”"
defaults write com.apple.finder FXInfoPanesExpanded -dict \
    General -bool true \
    OpenWith -bool true \
    Privileges -bool true;


###############################################################################
# "Dock & Dashboard"
###############################################################################

# "Auto hide dock"
defaults write com.apple.Dock autohide -int 1

# "Move dock orientation left"
defaults write com.apple.Dock orientation left

# "Enable highlight hover effect for the grid view of a stack (Dock)"
defaults write com.apple.dock mouse-over-hilite-stack -bool true;

# "Set the icon size of Dock items to 36 pixels"
defaults write com.apple.dock tilesize -int 36;

# "Change minimize/maximize window effect to scale"
defaults write com.apple.dock mineffect -string "scale";

# "Minimize windows into their application’s icon"
defaults write com.apple.dock minimize-to-application -bool true;

# "Enable spring loading for all Dock items"
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true;

# "Show indicator lights for open applications in the Dock"
defaults write com.apple.dock show-process-indicators -bool true;

# "Don’t animate opening applications from the Dock"
defaults write com.apple.dock launchanim -bool false;

# "Speed up Mission Control animations"
defaults write com.apple.dock expose-animation-duration -float 0.1;

# "Don’t group windows by application in Mission Control"
# (i.e. use the old Exposé behavior instead)
defaults write com.apple.dock expose-group-by-app -bool false;

# "Disable Dashboard"
defaults write com.apple.dashboard mcx-disabled -bool true;

# "Don’t show Dashboard as a Space"
defaults write com.apple.dock dashboard-in-overlay -bool true;

# "Don’t automatically rearrange Spaces based on most recent use"
defaults write com.apple.dock mru-spaces -bool false;

# "Remove the auto-hiding Dock delay"
defaults write com.apple.dock autohide-delay -float 0;

# "Remove the animation when hiding/showing the Dock"
defaults write com.apple.dock autohide-time-modifier -float 0;

# "Automatically hide and show the Dock"
defaults write com.apple.dock autohide -bool true;

# "Make Dock icons of hidden applications translucent"
defaults write com.apple.dock showhidden -bool true;

# "Make Dock more transparent"
defaults write com.apple.dock hide-mirror -bool true;

# "Reset Launchpad, but keep the desktop wallpaper intact"
find "${HOME}/Library/Application Support/Dock" -name "*-*.db" -maxdepth 1 -delete;

# "Configuring Hot Corners"
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center

# "Top left screen corner → Mission Control"
defaults write com.apple.dock wvous-tl-corner -int 0
defaults write com.apple.dock wvous-tl-modifier -int 0;
# "Top right screen corner → Desktop"
defaults write com.apple.dock wvous-tr-corner -int 0
defaults write com.apple.dock wvous-tr-modifier -int 0;
# "#tom right screen corner → Start screen saver"
defaults write com.apple.dock wvous-br-corner -int 0
defaults write com.apple.dock wvous-br-modifier -int 0;


###############################################################################
# "Configuring Safari & WebKit"
###############################################################################

# "Set Safari’s home page to ‘about:blank’ for faster loading"
defaults write com.apple.Safari HomePage -string "about:blank";

# "Prevent Safari from opening ‘safe’ files automatically after downloading"
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false;

# "Allow hitting the Backspace key to go to the previous page in history"
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true;

# "Hide Safari’s bookmarks bar by default"
defaults write com.apple.Safari ShowFavoritesBar -bool false;

# "Hide Safari’s sidebar in Top Sites"
defaults write com.apple.Safari ShowSidebarInTopSites -bool false;

# "Disable Safari’s thumbnail cache for History and Top Sites"
defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2;

# "Enable Safari’s debug menu"
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true;

# "Make Safari’s search banners default to Contains instead of Starts With"
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false;

# "Remove useless icons from Safari’s bookmarks bar"
defaults write com.apple.Safari ProxiesInBookmarksBar "()";

# "Enable the Develop menu and the Web Inspector in Safari"
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true;

# "Add a context menu item for showing the Web Inspector in web views"
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true;

# "Font size 10px min"
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2MinimumFontSize -int 10


###############################################################################
# "Configuring Mail"
###############################################################################

# "Disable send and reply animations in Mail.app"
defaults write com.apple.mail DisableReplyAnimations -bool true
defaults write com.apple.mail DisableSendAnimations -bool true;

# "Copy email addresses as 'foo@example.com' instead of 'Foo Bar <foo@example.com>' in Mail.app"
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false;

# "Add the keyboard shortcut ⌘ + Enter to send an email in Mail.app"
defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" -string "@\\U21a9";

# "Display emails in threaded mode, sorted by date (oldest at the top)"
defaults write com.apple.mail DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -string "yes"
defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortedDescending" -string "yes"
defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortOrder" -string "received-date";

# "Disable inline attachments (just show the icons)"
defaults write com.apple.mail DisableInlineAttachmentViewing -bool true;

# "Disable automatic spell checking"
defaults write com.apple.mail SpellCheckingBehavior -string "NoSpellCheckingEnabled";


###############################################################################
# "Time Machine"
###############################################################################

# "Prevent Time Machine from prompting to use new hard drives as backup volume"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true;

# "Disable local Time Machine backups"
hash tmutil &> /dev/null && sudo tmutil disablelocal;


###############################################################################
# "Activity Monitor"
###############################################################################

# "Show the main window when launching Activity Monitor"
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true;

# "Visualize CPU usage in the Activity Monitor Dock icon"
defaults write com.apple.ActivityMonitor IconType -int 5;

# "Show all processes in Activity Monitor"
defaults write com.apple.ActivityMonitor ShowCategory -int 0;

# "Sort Activity Monitor results by CPU usage"
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0;


###############################################################################
# "Address Book, Dashboard, iCal, TextEdit, and Disk Utility"
###############################################################################

# "Enable the debug menu in Address Book"
defaults write com.apple.addressbook ABShowDebugMenu -bool true;

# "Enable Dashboard dev mode (allows keeping widgets on the desktop)"
defaults write com.apple.dashboard devmode -bool true;

# "Use plain text mode for new TextEdit documents"
defaults write com.apple.TextEdit RichText -int 0;
# "Open and save files as UTF-8 in TextEdit"
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4;

# "Enable the debug menu in Disk Utility"
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
defaults write com.apple.DiskUtility advanced-image-options -bool true;


###############################################################################
# "keyboard shortcut setting"
###############################################################################
# "Mission control => Spaces Left - Control, Left"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 79 "{ enabled = 1; value = { parameters = ( 65535, 123, 262144 ); type = standard; }; }"

# "Mission control => Spaces Right - Control, Right"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 81 "{ enabled = 1; value = { parameters = ( 65535, 124, 262144 ); type = standard; }; }"

# "Spotlight => Show search field - Command, Shift, Space"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "{ enabled = 1; value = { parameters = ( 65535, 49, 1179648 ); type = standard; }; }"

# "Select the previous input source => Command, Space"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 60 "{ enabled = 1; value = { parameters = ( 32, 49, 1048576 ); type = standard; }; }"

# "Select the next source in the Input Menu => Command, Option, Space"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 61 "{ enabled = 1; value = { parameters = ( 32, 49, 1572864 ); type = standard; }; }"



###############################################################################
# "Security setting"
###############################################################################
# "Downloaded application install allow - Everywhere"
sudo spctl --master-disable
