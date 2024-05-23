#!/bin/bash

function command_exists() {
  hash "$1" &>/dev/null
}

function configuration() {
  export PATH="$HOME/Library/Application Support/fnm:$PATH" &>/dev/null
  eval "$(fnm env --use-on-cd)" &>/dev/null

  sed -i "s/eval \"\$(fnm env)\"//g" $HOME/.zshrc &>/dev/null
  sed -i "s/eval \"\$(fnm env --use-on-cd)\"//g" $HOME/.zshrc &>/dev/null
  
  echo '# fnm setup' >> ~/.zshrc
  echo 'eval "$(fnm env --use-on-cd)"' >> ~/.zshrc
  echo '' >> ~/.zshrc
}

# Check for fnm
if ! command_exists fnm; then
  echo "  Installing fnm for you."

  curl -fsSL https://fnm.vercel.app/install | bash
fi

configuration

# Check for jenv installed
fnm --version

# lts install
fnm install --lts --corepack-enabled --resolve-engines &>/dev/null

# add package manager
npm install -g yarn pnpm &>/dev/null

# Check for node installed
node -v
