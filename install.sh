#!/usr/bin/env bash

export DOTHOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# permission
chmod -R +wx ./bin

# Install brew with packages & casks
. "$DOTHOME/packages/homebrew/install.sh"

# Install fonts
. "$DOTHOME/fonts/install.sh"

# Install SpaceVim
. "$DOTHOME/packages/vim/install.sh"

# Setup macos defaults and add apps to dock
. "$DOTHOME/settings/macos/apply.sh"

# Setup git settings
. "$DOTHOME/settings/git/apply.sh"

# Setup vim settings
. "$DOTHOME/settings/vim/apply.sh"

# Setup zsh settings
. "$DOTHOME/settings/zsh/apply.sh"

# Setup apps settings
. "$DOTHOME/settings/apps/apply.sh"

# Clear cache
. "$DOTHOME/bin/dotfiles" clean