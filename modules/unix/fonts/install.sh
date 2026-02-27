#!/bin/bash
# modules/unix/fonts/install.sh — D2Coding 폰트 설치

ensure_dir "$FONT_DIR"

# 폰트 파일 복사
local found=0
for ext in ttf otf ttc pcf.gz; do
    for f in "$MODULE_DIR/files"/**/*."$ext" "$MODULE_DIR/files"/*."$ext"; do
        [[ -f "$f" ]] || continue
        copy_file "$f" "$FONT_DIR/$(basename "$f")"
        found=1
    done
done

# Linux: 폰트 캐시 갱신
if [[ "$OS" != "macos" ]] && has fc-cache; then
    fc-cache -f -v >/dev/null 2>&1
fi

if [[ $found -eq 1 ]]; then
    success "Fonts"
else
    warn "No font files found"
fi
