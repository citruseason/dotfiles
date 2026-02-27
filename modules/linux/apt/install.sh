#!/bin/bash
# modules/linux/apt/install.sh — 필수 시스템 패키지 설치

info "Updating apt cache..."
sudo apt-get update -qq

info "Installing essential packages..."
sudo apt-get install -y -qq \
    build-essential curl wget git git-lfs tree nmap zsh neovim unzip fontconfig

success "APT packages"
