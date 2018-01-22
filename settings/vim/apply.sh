#!/usr/bin/env bash

echo "Installing settings vim"

# SpaceVim.d 폴더가 없으면 생성
if [[ ! -d ~/.SpaceVim.d ]]; then
  mkdir ~/.SpaceVim.d
fi

# init.vim이 있으면 삭제 후 링크
if [[ -f ~/.SpaceVim.d/init.vim ]]; then
  sudo rm ~/.SpaceVim.d/init.vim
fi
sudo ln -s $DOTHOME/settings/vim/init.vim ~/.SpaceVim.d/init.vim
