#!/usr/bin/env bash
#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

function command_exists() {
  hash "$1" &> /dev/null
}

function configuration_nvm() {
  sed -i -e '/^export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"$/d' ~/.zshrc
  sed -i -e '/^[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"$/d' ~/.zshrc
  cat <<'EOF' >> ~/.zshrc
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
EOF
}

# Check for NVM 
if ! command_exists nvm; then
  echo "  Installing nvm for you."

  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.2/install.sh | bash
  configuration_nvm
  source ~/.zshrc
fi

# Check for n installed
nvm --version

# LTS install
nvm install --lts

# Check for node installed
node -v
