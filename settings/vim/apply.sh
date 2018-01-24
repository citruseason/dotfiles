#!/usr/bin/env bash

echo "Installing settings vim"

mkdir -p $DOTCDIR/.SpaceVim.d && cp -r $DOTHOME/settings/vim/init.vim $DOTCDIR/.SpaceVim.d

# if [[ ! -d $HOME/.SpaceVim.d ]]; then
#   mkdir $HOME/.SpaceVim.d
# fi

# if [[ -f $HOME/.SpaceVim.d/init.vim ]]; then
#   sudo rm $HOME/.SpaceVim.d/init.vim
# fi
# sudo ln -s $DOTHOME/settings/vim/init.vim $HOME/.SpaceVim.d/init.vim

echo "Done! Vim is set."