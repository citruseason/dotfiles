#!/usr/bin/env bash
#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

function command_exists() {
  hash "$1" &> /dev/null
}

function configuration_n() {
  sed -i -e '/^export N_PREFIX\=$HOME\/\.n$/d' ~/.zshrc
  sed -i -e '/^export PATH\=$N_PREFIX\/bin\:$PATH$/d' ~/.zshrc
  cat <<'EOF' >> ~/.zshrc
export N_PREFIX=$HOME/.n
export PATH=$N_PREFIX/bin:$PATH
EOF
}

# Check for NVM 
if ! command_exists n; then
  echo "  Installing n for you."

  if [[ "$DOT_OS_NAME" == "osx" ]]; then
	  brew install n
  elif [[ "$DOT_OS_NAME" == "linux" ]]; then
    curl -L https://git.io/n-install | bash
  fi
  configuration_n
	source ~/.zshrc
fi

# Check for n installed
n -V

# LTS install
n lts

# Check for node installed
node -v
