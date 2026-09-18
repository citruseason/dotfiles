#!/bin/bash
# 앱의 내보내기 형식에서 설정을 꺼내 복원합니다. Bash 3.2 호환.

settings_file="$MODULE_DIR/files/settings.plist"
domain="com.vorssaint.utils"

if pgrep -x Vorssaint >/dev/null; then
    fail "Vorssaint를 종료한 뒤 dotfiles --tags vorssaint를 다시 실행하세요."
fi

if [[ "$(plutil -extract vorssaintBackupVersion raw "$settings_file" 2>/dev/null)" != 1 ]]; then
    fail "지원하지 않는 Vorssaint 백업 형식입니다."
fi
if [[ "$(plutil -type settings "$settings_file" 2>/dev/null)" != dictionary ]]; then
    fail "Vorssaint 백업에 settings 딕셔너리가 없습니다."
fi

umask 077
restore_dir=$(mktemp -d) || fail "복원 임시 폴더를 만들지 못했습니다."
trap 'rm -rf "$restore_dir"' EXIT
if ! plutil -extract settings xml1 -o "$restore_dir/settings.plist" "$settings_file"; then
    fail "Vorssaint 설정을 읽지 못했습니다."
fi

# 기존 설정을 백업한 뒤 저장된 항목을 덮어씁니다. 백업 실패 시 복원하지 않습니다.
if defaults read "$domain" >/dev/null 2>&1; then
    backup_dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/backups/vorssaint"
    ensure_dir "$backup_dir" || fail "백업 폴더를 만들지 못했습니다."
    backup_file=$(mktemp "$backup_dir/settings.XXXXXXXX") || fail "백업 파일을 만들지 못했습니다."
    if ! defaults export "$domain" "$backup_file"; then
        rm -f "$backup_file"
        fail "기존 Vorssaint 설정을 백업하지 못했습니다."
    fi
    mv "$backup_file" "$backup_file.plist" || fail "백업 파일을 저장하지 못했습니다."
    info "기존 설정 백업: $backup_file.plist"
fi

if ! defaults import "$domain" "$restore_dir/settings.plist"; then
    fail "Vorssaint 설정 복원에 실패했습니다."
fi
success "Vorssaint 설정 복원 완료 — 앱을 실행하면 적용됩니다."
