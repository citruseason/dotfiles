#!/bin/bash
# modules/unix/git/install.sh — Git 설정 파일 복사

copy_file "$MODULE_DIR/files/.gitconfig"          "$HOME/.gitconfig"
copy_file "$MODULE_DIR/files/.gitconfig-personal"  "$HOME/.gitconfig-personal"
copy_file "$MODULE_DIR/files/.gitconfig-company"   "$HOME/.gitconfig-company"
copy_file "$MODULE_DIR/files/.gitignore_global"    "$HOME/.gitignore_global"

success "Git config"
