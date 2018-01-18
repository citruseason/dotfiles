#!/usr/bin/env bash

export DOTHOME EXTRA_DIR
DOTHOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# permission
chmod -R +wx ./bin

# Install brew with packages & casks
. "$DOTHOME/packages/homebrew/install.sh"

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

# Clear cache
. "$DOTHOME/bin/dotfiles" clean