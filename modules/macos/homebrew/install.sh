#!/bin/bash
# modules/macos/homebrew/install.sh — Homebrew 패키지 관리
# 패키지 목록은 Brewfile / Brewfile.private 에서 선언적으로 관리

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

# ── 서드파티 tap 신뢰 ──
# Brewfile의 tap 항목은 trust까지 처리하지 못하므로 bundle 전에 실행
brew tap slp/krunkit 2>/dev/null || true
brew trust slp/krunkit 2>/dev/null || true

# ── Homebrew 업데이트 ──
info "Updating Homebrew..."
brew update --quiet

# ── Brewfile 설치 ──
# --no-upgrade: 설치만 하고 기존 패키지는 업그레이드하지 않음 (빠른 멱등 실행)
# cask는 brew bundle이 --adopt를 자동 적용 (기존 설치 앱을 brew 관리로 편입)
info "Installing packages from Brewfile..."
if ! brew bundle install --file="$MODULE_DIR/Brewfile" --no-upgrade; then
    warn "일부 패키지 설치 실패 — 위 로그를 확인하세요"
fi
success "Brewfile"

# ── Private 패키지 (personal 프로필만) ──
if [[ "${HOMEBREW_INSTALL_PRIVATE}" == "true" ]]; then
    info "Installing packages from Brewfile.private..."
    if ! brew bundle install --file="$MODULE_DIR/Brewfile.private" --no-upgrade; then
        warn "일부 항목 설치 실패 — mas 앱은 App Store 로그인이 필요합니다"
    fi
    success "Brewfile.private"

    # ── CLI tools (공식 설치 스크립트) ──
    # brew 대신 공식 도큐먼트 권장 방식으로 설치 (자동 업데이트 지원)
    if ! has claude; then
        info "Installing Claude Code..."
        curl -fsSL https://claude.ai/install.sh | bash 2>/dev/null || true
    fi
    success "Claude Code"

    if ! has codex; then
        info "Installing Codex..."
        curl -fsSL https://chatgpt.com/codex/install.sh | sh 2>/dev/null || true
    fi
    success "Codex"
fi

success "Homebrew"
