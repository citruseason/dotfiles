#!/bin/bash
# lib/config.sh — 변수 로더: common → os → profile 순서

# 명시적 순서: common → OS → profile. 나중 파일이 앞 파일 덮어씀.
load_config() {
    . "$DOTFILES_DIR/config/common.sh"
    . "$DOTFILES_DIR/config/${OS}.sh" 2>/dev/null || true
    [[ -n "${PROFILE:-}" ]] && . "$DOTFILES_DIR/config/${PROFILE}.sh" 2>/dev/null || true
}
