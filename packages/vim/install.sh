#!/usr/bin/env bash

if [[ ! -d "$HOME/.config" ]]; then
    mkdir $HOME/.config
fi

# Remove old spacevim
curl -sLf https://spacevim.org/install.sh | bash -s -- --uninstall

curl -sLf https://spacevim.org/install.sh | bash

echo "Done! Vim is installed."