#!/bin/bash
# modules/unix/tmux/install.sh — tmux 설정 파일 복사

copy_file "$MODULE_DIR/files/.tmux.conf" "$HOME/.tmux.conf"

success "Tmux config"
