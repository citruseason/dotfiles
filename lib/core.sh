#!/bin/bash
# lib/core.sh — 색상, 로깅, OS 감지, 파일 헬퍼, 멱등성 유틸
# Bash 3.2 호환: declare -A, local -n, readarray 사용 금지

# ── Colors ────────────────────────────────────────────
BOLD=$'\033[1m'
DIM=$'\033[2m'
RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
CYAN=$'\033[36m'
NC=$'\033[0m'

# ── Logging ───────────────────────────────────────────
info()    { printf '  %b%s%b\n' "$CYAN" "$1" "$NC"; }
success() { printf '  %b✓ %s%b\n' "$GREEN" "$1" "$NC"; }
warn()    { printf '  %b! %s%b\n' "$YELLOW" "$1" "$NC"; }
fail()    { printf '  %b✗ %s%b\n' "$RED" "$1" "$NC" >&2; exit 1; }
step()    { printf '\n%b  %s%b\n' "$BOLD" "$1" "$NC"; }

# ── OS Detection ─────────────────────────────────────
OS="${OS:-}"

detect_os() {
    case "$(uname -s)" in
        Darwin) OS="macos" ;;
        Linux)
            if grep -qi microsoft /proc/version 2>/dev/null; then
                OS="wsl"
            else
                OS="linux"
            fi
            ;;
        *) fail "Unsupported OS: $(uname -s)" ;;
    esac
}

# ── Utility ──────────────────────────────────────────
has() { command -v "$1" &>/dev/null; }

# ── File Helpers (멱등성) ────────────────────────────

# 디렉토리가 없으면 생성
ensure_dir() {
    local dir="$1"
    [[ -d "$dir" ]] && return 0
    mkdir -p "$dir"
}

# 파일 복사: 동일하면 건너뜀, 다르면 백업 후 복사
copy_file() {
    local src="$1" dest="$2"
    if [[ -f "$dest" ]] && cmp -s "$src" "$dest"; then
        return 0
    fi
    if [[ -f "$dest" ]]; then
        cp "$dest" "${dest}.bak.$(date +%s)"
    fi
    ensure_dir "$(dirname "$dest")"
    cp "$src" "$dest"
}

# grep 후 없으면 줄 추가 (lineinfile 대체)
ensure_line() {
    local file="$1" line="$2"
    [[ -f "$file" ]] || touch "$file"
    grep -qF "$line" "$file" 2>/dev/null && return 0
    printf '%s\n' "$line" >> "$file"
}

# Git clone 또는 pull
clone_or_pull() {
    local repo="$1" dest="$2"
    if [[ -d "$dest/.git" ]]; then
        git -C "$dest" pull --quiet 2>/dev/null || true
    else
        ensure_dir "$(dirname "$dest")"
        git clone --depth 1 "$repo" "$dest"
    fi
}

# 블록 주입 (perl 사용 — BSD/GNU sed 호환 문제 회피)
inject_block() {
    local file="$1" marker="$2" content="$3"
    local begin="# BEGIN ${marker}" end="# END ${marker}"
    [[ -f "$file" ]] || touch "$file"
    # 기존 블록 제거
    if grep -qF "$begin" "$file"; then
        perl -i -0pe "s/\Q${begin}\E\n.*?\Q${end}\E\n//s" "$file"
    fi
    # 새 블록 추가
    printf '\n%s\n%s\n%s\n' "$begin" "$content" "$end" >> "$file"
}

# curl 래퍼: HTTP 상태 검증
download() {
    local url="$1" dest="$2"
    curl -fsSL "$url" -o "$dest"
}
