#!/bin/bash
# modules/macos/homebrew/install.sh — Homebrew 패키지 관리

# ── Homebrew 설치 확인 ──
if ! has brew; then
    info "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi
success "Homebrew"

# ── deprecated tap 제거 ──
brew untap homebrew/cask-versions 2>/dev/null || true
brew untap homebrew/cask-fonts 2>/dev/null || true

# ── tap 추가 ──
brew tap slp/krunkit 2>/dev/null || true

# ── Homebrew 업데이트 ──
info "Updating Homebrew..."
brew update --quiet

# ── Formulae ──
FORMULAE=(
    # CLI Tools
    git git-lfs diff-so-fancy mas wget tree dockutil mise mole nmap tmux
    # Shell
    zsh starship vivid coreutils
    # Editor
    neovim
    # Container
    kubectl krunkit
)

info "Installing formulae..."
for pkg in "${FORMULAE[@]}"; do
    brew install "$pkg" 2>/dev/null || true
done
success "Formulae"

# ── Casks ──
CASKS=(
    ghostty podman-desktop google-chrome zen slack notion iina
    scroll-reverser appcleaner
    font-hack-nerd-font
)

info "Installing casks..."
for cask in "${CASKS[@]}"; do
    brew install --cask --adopt "$cask" 2>/dev/null || true
done
success "Casks"

# ── Private casks (personal 프로필만) ──
if [[ "${HOMEBREW_INSTALL_PRIVATE}" == "true" ]]; then
    PRIVATE_CASKS=(
        karabiner-elements 1password antigravity telegram tailscale
        claude-code codex discord
    )

    info "Installing private casks..."
    for cask in "${PRIVATE_CASKS[@]}"; do
        brew install --cask --adopt "$cask" 2>/dev/null || true
    done
    success "Private casks"

    # ── Mac App Store ──
    MAS_APPS=(
        "1265704574:Bandizip"
        "441258766:Magnet"
        "869223134:KakaoTalk"
    )

    info "Installing Mac App Store apps..."
    local failed_apps=()
    for entry in "${MAS_APPS[@]}"; do
        local app_id="${entry%%:*}"
        local app_name="${entry#*:}"
        if ! mas install "$app_id" 2>/dev/null; then
            failed_apps+=("$app_name")
        fi
    done

    if [[ ${#failed_apps[@]} -gt 0 ]]; then
        local IFS=', '
        warn "다음 앱은 App Store에서 직접 설치하세요: ${failed_apps[*]}"
    fi
    success "Mac App Store apps"
fi

success "Homebrew"
