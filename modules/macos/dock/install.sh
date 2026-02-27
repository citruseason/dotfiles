#!/bin/bash
# modules/macos/dock/install.sh — Dock 레이아웃 설정

if ! has dockutil; then
    warn "dockutil not found, skipping Dock setup"
    return 0
fi

# ── 모든 Dock 아이템 제거 ──
info "Removing all Dock items..."
dockutil --no-restart --remove all

# ── 앱 추가 ──
info "Adding Dock apps..."
for app in "${DOCK_APPS[@]}"; do
    dockutil --no-restart --add "$app" 2>/dev/null || true
done

# ── 폴더 추가 ──
info "Adding Dock folders..."
for entry in "${DOCK_FOLDERS[@]}"; do
    local IFS='|'
    set -- $entry
    local path="$1" display="$2" sort="$3"
    dockutil --no-restart --add "$path" --display "$display" --sort "$sort" --before Trash 2>/dev/null || true
done

# ── Dock 재시작 ──
killall Dock 2>/dev/null || true

success "Dock"
