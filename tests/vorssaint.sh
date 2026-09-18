#!/bin/bash
# 실제 앱·환경설정을 건드리지 않고 복원 계약을 검증합니다.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
fixture_dir=$(mktemp -d)
trap 'rm -rf "$fixture_dir"' EXIT
export XDG_STATE_HOME="$fixture_dir/state"
export MODULE_DIR="$DOTFILES_DIR/modules/macos/vorssaint"
. "$DOTFILES_DIR/lib/core.sh"

defaults() {
    case "$1" in
        read) [[ "${existing:-true}" == true ]] ;;
        export)
            [[ "${export_failure:-false}" == false ]] || return 1
            printf 'previous settings' > "$3"
            ;;
        import)
            [[ "${import_failure:-false}" == false ]] || return 1
            cp "$3" "$fixture_dir/imported.plist"
            ;;
        *) return 1 ;;
    esac
}
pgrep() { [[ "${running:-false}" == true ]]; }
run_restore() { ( . "$DOTFILES_DIR/modules/macos/vorssaint/install.sh" ); }

run_restore
plutil -lint "$fixture_dir/imported.plist"
plutil -extract settings xml1 -o "$fixture_dir/expected.plist" "$MODULE_DIR/files/settings.plist"
cmp "$fixture_dir/expected.plist" "$fixture_dir/imported.plist"
backup_count=$(find "$XDG_STATE_HOME" -name '*.plist' | wc -l | tr -d ' ')
[[ "$backup_count" == 1 ]]
run_restore
[[ "$(find "$XDG_STATE_HOME" -name '*.plist' | wc -l | tr -d ' ')" == 2 ]]

rm "$fixture_dir/imported.plist"
running=true
if run_restore; then echo 'FAIL: 실행 중인 앱 설정을 덮어썼습니다'; exit 1; fi
[[ ! -f "$fixture_dir/imported.plist" ]]
running=false
export_failure=true
if run_restore; then echo 'FAIL: 백업 실패를 무시했습니다'; exit 1; fi
[[ ! -f "$fixture_dir/imported.plist" ]]
export_failure=false
import_failure=true
if run_restore; then echo 'FAIL: 복원 실패를 무시했습니다'; exit 1; fi
import_failure=false
existing=false
run_restore
[[ -f "$fixture_dir/imported.plist" ]]

saved_module_dir="$MODULE_DIR"
MODULE_DIR="$fixture_dir/invalid"
mkdir -p "$MODULE_DIR/files"
cp "$saved_module_dir/files/settings.plist" "$MODULE_DIR/files/settings.plist"
plutil -replace vorssaintBackupVersion -integer 999 "$MODULE_DIR/files/settings.plist"
if run_restore; then echo 'FAIL: 지원하지 않는 형식을 가져왔습니다'; exit 1; fi
plutil -replace vorssaintBackupVersion -integer 1 "$MODULE_DIR/files/settings.plist"
plutil -replace settings -string invalid "$MODULE_DIR/files/settings.plist"
if run_restore; then echo 'FAIL: 잘못된 settings를 가져왔습니다'; exit 1; fi
MODULE_DIR="$saved_module_dir"

# macOS에만 등록되어야 합니다.
. "$DOTFILES_DIR/lib/module.sh"
OS=macos
load_registry
find_tag_index vorssaint >/dev/null
OS=linux
load_registry
if find_tag_index vorssaint >/dev/null; then exit 1; fi
echo 'PASS: 복원, 반복 실행, 실행 중 차단, 백업·복원 오류, 새 설치, 잘못된 파일 거부, OS 필터'
