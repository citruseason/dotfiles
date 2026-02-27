#!/bin/bash
# modules/unix/mise/install.sh — mise 설치 및 설정

# mise 바이너리 경로 결정
if [[ "$OS" == "macos" ]]; then
    MISE_BIN="mise"
else
    MISE_BIN="$HOME/.local/bin/mise"
fi

# mise 설치
if ! has mise; then
    if [[ "$OS" == "macos" ]]; then
        brew install mise
    else
        ensure_dir "$HOME/.local/bin"
        curl https://mise.run | sh
    fi
fi

# 설정 파일 복사
copy_file "$MODULE_DIR/files/.mise.toml" "$HOME/.mise.toml"

# conf.d 복사
ensure_dir "$HOME/.config/shell/conf.d"
copy_file "$MODULE_DIR/files/conf.d/100-mise.sh" "$HOME/.config/shell/conf.d/100-mise.sh"

# mise trust & install
"$MISE_BIN" trust "$HOME/.mise.toml" 2>/dev/null || true
info "Installing mise tools (this may take a while)..."
"$MISE_BIN" install --yes

success "Mise"
