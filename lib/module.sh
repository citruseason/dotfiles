#!/bin/bash
# lib/module.sh — 모듈 러너: 발견, 훅, 서브셸 실행, resume
# Bash 3.2 호환: declare -A, local -n, readarray 사용 금지

# ── Registry (병렬 배열) ─────────────────────────────
_REG_TAGS=()
_REG_PATHS=()
_REG_LABELS=()
_REG_DESCS=()
_REG_CATEGORIES=()

# ── OS 필터 ──────────────────────────────────────────
module_applies() {
    local mod_os="$1"
    case "$mod_os" in
        all)   return 0 ;;
        macos) [[ "$OS" == "macos" ]] ;;
        linux) [[ "$OS" == "linux" || "$OS" == "wsl" ]] ;;
        wsl)   [[ "$OS" == "wsl" ]] ;;
    esac
}

# ── 태그 하위호환 ────────────────────────────────────
normalize_tag() {
    case "$1" in
        cli)   printf 'dotfiles-cli' ;;
        macos) printf 'macos-defaults' ;;
        wsl)   printf 'wsl-ubuntu-setup' ;;
        *)     printf '%s' "$1" ;;
    esac
}

# ── 레지스트리 로드 ──────────────────────────────────
load_registry() {
    _REG_TAGS=()
    _REG_PATHS=()
    _REG_LABELS=()
    _REG_DESCS=()
    _REG_CATEGORIES=()

    while IFS= read -r path || [[ -n "$path" ]]; do
        [[ -z "$path" || "$path" == \#* ]] && continue
        local conf="$DOTFILES_DIR/modules/$path/module.conf"
        [[ -f "$conf" ]] || continue

        # 임시 변수에 소싱
        local TAG="" LABEL="" DESC="" CATEGORY="" OS_FILTER=""
        . "$conf"

        # OS 필터 확인
        if ! module_applies "$OS_FILTER"; then continue; fi

        # 런타임 배열에 추가
        _REG_TAGS+=("$TAG")
        _REG_PATHS+=("$path")
        _REG_LABELS+=("$LABEL")
        _REG_DESCS+=("$DESC")
        _REG_CATEGORIES+=("$CATEGORY")
    done < "$DOTFILES_DIR/modules/order.conf"
}

# ── 태그로 인덱스 찾기 ──────────────────────────────
find_tag_index() {
    local tag="$1"
    local i
    for i in "${!_REG_TAGS[@]}"; do
        if [[ "${_REG_TAGS[$i]}" == "$tag" ]]; then
            printf '%d' "$i"
            return 0
        fi
    done
    return 1
}

# ── 모듈 실행: 서브셸 격리 ──────────────────────────
run_module() {
    local idx="$1" total="$2" display_num="${3:-}"
    local tag="${_REG_TAGS[$idx]}" path="${_REG_PATHS[$idx]}" label="${_REG_LABELS[$idx]}"
    local module_dir="$DOTFILES_DIR/modules/$path"
    [[ -z "$display_num" ]] && display_num=$((idx+1))

    printf '\n━━━ [%d/%d] %s ━━━\n' "$display_num" "$total" "$label"

    set +e
    (
        export MODULE_DIR="$module_dir"
        export DOTFILES_DIR
        export OS
        export PROFILE
        . "$DOTFILES_DIR/lib/core.sh"
        . "$DOTFILES_DIR/lib/config.sh"
        load_config

        # pre-install (선택적)
        if [[ -f "$module_dir/pre-install.sh" ]]; then . "$module_dir/pre-install.sh"; fi
        # install
        . "$module_dir/install.sh"
        # post-install (선택적)
        if [[ -f "$module_dir/post-install.sh" ]]; then . "$module_dir/post-install.sh"; fi
    )
    local rc=$?
    set -e

    if [[ $rc -ne 0 ]]; then
        printf '━━━ FAILED at: %s ━━━\n' "$tag"
        printf '  Resume: dotfiles --resume\n'
        printf '  Retry:  dotfiles --tags %s\n' "$tag"
        return $rc
    fi

    # 성공 마커 기록
    ensure_dir "$HOME/.local/state/dotfiles"
    date +%s > "$HOME/.local/state/dotfiles/$tag.done"
}

# ── 모듈 목록 실행 ──────────────────────────────────
run_modules() {
    local total=${#_REG_TAGS[@]}
    local i n=1
    for i in "${!_REG_TAGS[@]}"; do
        run_module "$i" "$total" "$n" || return $?
        n=$((n + 1))
    done
}

# ── 태그 필터로 실행 ────────────────────────────────
run_modules_by_tags() {
    local tag_str="$1"
    local total=0
    local indices=()

    IFS=',' read -ra tags <<< "$tag_str"
    local t
    for t in "${tags[@]}"; do
        t=$(normalize_tag "$t")
        local idx
        idx=$(find_tag_index "$t") || { warn "Unknown tag: $t"; continue; }
        indices+=("$idx")
        total=$((total + 1))
    done

    if [[ $total -eq 0 ]]; then
        warn "No matching modules found"
        return 1
    fi

    local n=1
    local idx
    for idx in "${indices[@]}"; do
        run_module "$idx" "$total" "$n" || return $?
        n=$((n + 1))
    done
}

# ── Resume 지원 ─────────────────────────────────────
RESUME_FILE="$HOME/.local/state/dotfiles/.resume"

save_resume_state() {
    local profile="$1" failed_tag="$2" tags="$3"
    ensure_dir "$(dirname "$RESUME_FILE")"
    cat > "$RESUME_FILE" <<EOF
PROFILE=$profile
FAILED_TAG=$failed_tag
TAGS=$tags
EOF
}

load_resume_state() {
    [[ -f "$RESUME_FILE" ]] || return 1
    . "$RESUME_FILE"
}

clear_resume_state() {
    rm -f "$RESUME_FILE"
}

# ── 모듈 상태 목록 ──────────────────────────────────
list_modules() {
    local i
    for i in "${!_REG_TAGS[@]}"; do
        local tag="${_REG_TAGS[$i]}"
        local desc="${_REG_DESCS[$i]}"
        local state_file="$HOME/.local/state/dotfiles/${tag}.done"
        local mark="${RED}✗${NC}"
        [[ -f "$state_file" ]] && mark="${GREEN}✓${NC}"
        printf '  %-18s %b  %s\n' "$tag" "$mark" "$desc"
    done
}

# ── 동적 help ────────────────────────────────────────
show_module_help() {
    printf 'Usage: dotfiles [options]\n\n'
    printf 'Options:\n'
    printf '  (none)           Interactive TUI mode\n'
    printf '  --all            Run all modules\n'
    printf '  --tags t1,t2     Run specific modules by tag\n'
    printf '  --list           Show module status\n'
    printf '  --resume         Resume from last failure\n'
    printf '  --help, -h       Show this help\n'
    printf '\nAvailable modules (%s):\n' "$OS"

    local prev_cat="" i
    for i in "${!_REG_TAGS[@]}"; do
        local cat="${_REG_CATEGORIES[$i]}"
        if [[ "$cat" != "$prev_cat" ]]; then
            printf '\n  %s:\n' "$cat"
            prev_cat="$cat"
        fi
        printf '    %-18s %s\n' "${_REG_TAGS[$i]}" "${_REG_DESCS[$i]}"
    done
    printf '\n'
}
