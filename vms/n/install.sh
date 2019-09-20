#!/usr/bin/env bash
#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

function configuration_n() {

sed -i -e '/^export N_PREFIX\=$HOME\/\.n$/d' ~/.zshrc
sed -i -e '/^export PATH\=$N_PREFIX\/bin\:$PATH$/d' ~/.zshrc

cat <<'EOF' >> ~/.zshrc
export N_PREFIX=$HOME/.n
export PATH=$N_PREFIX/bin:$PATH
EOF

}

# Check for NVM 
if [[ ! $(which n) ]]; then
  echo "  Installing n for you."

  if [[ MACOS ]]; then
	brew install n
	configuration_n
	source ~/.zshrc
  fi

fi

# Check for n installed
n -V

# LTS install
n lts

# Check for node installed
node -v
