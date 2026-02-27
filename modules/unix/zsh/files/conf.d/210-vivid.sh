# LS_COLORS (vivid)
if command -v vivid &>/dev/null; then
    export LS_COLORS="$(vivid generate snazzy)"
fi
