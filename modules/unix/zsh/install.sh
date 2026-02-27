#!/bin/bash
# modules/unix/zsh/install.sh — Zsh 설치, 플러그인, 설정

# ── Linux: zsh 설치 ──
if [[ "$OS" != "macos" ]]; then
    if ! has zsh; then
        info "Installing zsh..."
        sudo apt-get install -y -qq zsh
    fi
fi

# ── .zshrc 복사 ──
copy_file "$MODULE_DIR/files/.zshrc" "$HOME/.zshrc"

# ── Aliases 복사 ──
copy_file "$MODULE_DIR/files/.aliases" "$HOME/.aliases"

# 플랫폼별 aliases
case "$OS" in
    wsl)   copy_file "$MODULE_DIR/files/.aliases_wsl"   "$HOME/.aliases_platform" ;;
    macos) copy_file "$MODULE_DIR/files/.aliases_macos"  "$HOME/.aliases_platform" ;;
    *)     copy_file "$MODULE_DIR/files/.aliases_linux"  "$HOME/.aliases_platform" ;;
esac

# ── Zsh 플러그인 ──
ensure_dir "$HOME/.zsh/plugins"

clone_or_pull "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
    "$HOME/.zsh/plugins/zsh-syntax-highlighting"
clone_or_pull "https://github.com/zsh-users/zsh-autosuggestions.git" \
    "$HOME/.zsh/plugins/zsh-autosuggestions"
clone_or_pull "https://github.com/zsh-users/zsh-completions.git" \
    "$HOME/.zsh/plugins/zsh-completions"
success "Zsh plugins"

# ── Starship 설정 ──
ensure_dir "$HOME/.config"
copy_file "$MODULE_DIR/files/starship.toml" "$HOME/.config/starship.toml"

# Linux: Starship 설치
if [[ "$OS" != "macos" ]] && ! has starship; then
    ensure_dir "$HOME/.local/bin"
    info "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
fi

# ── conf.d 복사 ──
ensure_dir "$HOME/.config/shell/conf.d"
copy_file "$MODULE_DIR/files/conf.d/000-path.sh"     "$HOME/.config/shell/conf.d/000-path.sh"
copy_file "$MODULE_DIR/files/conf.d/200-starship.sh"  "$HOME/.config/shell/conf.d/200-starship.sh"
copy_file "$MODULE_DIR/files/conf.d/210-vivid.sh"     "$HOME/.config/shell/conf.d/210-vivid.sh"

# ── 기존 .zshrc_extra 제거 (conf.d로 이전) ──
rm -f "$HOME/.zshrc_extra"

# ── 기본 셸을 zsh로 설정 ──
local zsh_path
zsh_path="$(which zsh)"
if [[ -n "$zsh_path" ]]; then
    # /etc/shells에 등록
    if ! grep -qF "$zsh_path" /etc/shells 2>/dev/null; then
        sudo sh -c "echo '$zsh_path' >> /etc/shells"
    fi
    # 기본 셸 변경
    if [[ "$SHELL" != "$zsh_path" ]]; then
        sudo chsh -s "$zsh_path" "$(whoami)"
    fi
fi

success "Zsh"
