#!/bin/bash
# modules/unix/apps/install.sh — Ghostty 터미널 설정

ensure_dir "$HOME/.config/ghostty"
copy_file "$MODULE_DIR/files/ghostty.config" "$HOME/.config/ghostty/config"

success "Ghostty config"
