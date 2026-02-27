#!/bin/bash
set -euo pipefail

# ── Configuration (override via env vars) ─────────────
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/citruseason/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
PROFILE="${PROFILE:-}"
SKIP_REPO_UPDATE="${SKIP_REPO_UPDATE:-0}"
RESUME_MODE=0

# ── Colors ────────────────────────────────────────────
BOLD=$'\033[1m'
DIM=$'\033[2m'
RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
CYAN=$'\033[36m'
NC=$'\033[0m'

# ── Helpers ───────────────────────────────────────────
info()    { printf '  %b%s%b\n' "$CYAN" "$1" "$NC"; }
success() { printf '  %b✓ %s%b\n' "$GREEN" "$1" "$NC"; }
warn()    { printf '  %b! %s%b\n' "$YELLOW" "$1" "$NC"; }
fail()    { printf '  %b✗ %s%b\n' "$RED" "$1" "$NC" >&2; exit 1; }
step()    { printf '\n%b  %s%b\n' "$BOLD" "$1" "$NC"; }
has()     { command -v "$1" &>/dev/null; }

# ── OS Detection ──────────────────────────────────────
OS=""

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

detect_profile() {
    if [[ -n "$PROFILE" ]]; then
        return
    fi
    case "$OS" in
        macos) PROFILE="personal" ;;
        wsl)   PROFILE="wsl" ;;
        linux) PROFILE="ubuntu" ;;
    esac
}

# ── Sudo keep-alive ──────────────────────────────────
SUDO_PID=""

acquire_sudo() {
    if [[ "$OS" == "macos" ]] || [[ "$OS" == "linux" ]] || [[ "$OS" == "wsl" ]]; then
        if ! sudo -n true 2>/dev/null; then
            info "Sudo password required for system configuration"
            sudo -v
        fi
        # Keep sudo timestamp alive in background
        (while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done) &
        SUDO_PID=$!
    fi

    # Allow passwordless sudo for dotfiles provisioning
    local sudoers_file="/etc/sudoers.d/dotfiles"
    local sudoers_rule="$(whoami) ALL=(ALL) NOPASSWD:SETENV: ALL"
    if [[ ! -f "$sudoers_file" ]] || ! grep -qF "$sudoers_rule" "$sudoers_file" 2>/dev/null; then
        sudo sh -c "echo '$sudoers_rule' > $sudoers_file && chmod 0440 $sudoers_file"
        success "Dotfiles sudoers rule"
    fi
}

cleanup_sudo() {
    [[ -n "$SUDO_PID" ]] && kill "$SUDO_PID" 2>/dev/null || true
}
trap cleanup_sudo EXIT

# ── macOS: Xcode Command Line Tools ──────────────────
install_xcode_clt() {
    if [[ -f "/Library/Developer/CommandLineTools/usr/bin/git" ]]; then
        success "Xcode CLT"
        return
    fi

    info "Installing Xcode Command Line Tools..."

    local clt_placeholder="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
    sudo touch "$clt_placeholder"

    local clt_package
    clt_package=$(softwareupdate -l 2>/dev/null \
        | grep -B 1 -E "Command Line Tools" \
        | awk -F'*' '/^ *\*/ {print $2}' \
        | sed -e 's/^ *Label: //' -e 's/^ *//' \
        | sort -V \
        | tail -n 1)

    if [[ -n "$clt_package" ]]; then
        sudo softwareupdate -i "$clt_package" --verbose
    fi

    sudo rm -f "$clt_placeholder"

    if [[ -f "/Library/Developer/CommandLineTools/usr/bin/git" ]]; then
        sudo xcode-select --switch /Library/Developer/CommandLineTools
    elif [[ -t 0 ]]; then
        warn "Headless install failed, requesting GUI install..."
        xcode-select --install
        info "Press any key when installation has completed."
        read -n 1 -s -r
    else
        fail "Xcode CLT install failed. Run 'xcode-select --install' manually."
    fi

    success "Xcode CLT"
}

# ── macOS: Homebrew ───────────────────────────────────
install_homebrew() {
    if has brew; then
        success "Homebrew"
        return
    fi

    info "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    success "Homebrew"
}

# ── Linux: git ────────────────────────────────────────
install_git_linux() {
    if has git; then
        success "Git"
        return
    fi

    info "Installing Git..."
    if has apt-get; then
        sudo apt-get update -qq
        sudo apt-get install -y -qq git
    elif has dnf; then
        sudo dnf install -y git
    fi
    success "Git"
}

# ── Clone/Update Repo ────────────────────────────────
clone_dotfiles() {
    if [[ -d "$DOTFILES_DIR/.git" ]]; then
        if [[ "$SKIP_REPO_UPDATE" == "1" ]]; then
            info "Skipping repo update (SKIP_REPO_UPDATE=1)"
        else
            info "Updating dotfiles repo..."
            git -C "$DOTFILES_DIR" pull --rebase --quiet
            success "Dotfiles updated ($DOTFILES_DIR)"
        fi
    else
        info "Cloning dotfiles repo..."
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
        success "Dotfiles cloned ($DOTFILES_DIR)"
    fi
}

# ── Run Modules ──────────────────────────────────────
run_dotfiles() {
    local tag_str="${1:-}"

    # Source libraries
    . "$DOTFILES_DIR/lib/core.sh"
    . "$DOTFILES_DIR/lib/config.sh"
    . "$DOTFILES_DIR/lib/module.sh"

    export DOTFILES_DIR OS PROFILE
    load_config
    load_registry

    if [[ -n "$tag_str" ]]; then
        info "Running modules: $tag_str (profile: $PROFILE)"
        run_modules_by_tags "$tag_str"
    else
        info "Running all modules (profile: $PROFILE)"
        local total=${#_REG_TAGS[@]}
        local i
        for i in "${!_REG_TAGS[@]}"; do
            run_module "$i" "$total" || {
                local tag="${_REG_TAGS[$i]}"
                local remaining=()
                local j
                for j in "${!_REG_TAGS[@]}"; do
                    [[ $j -ge $i ]] && remaining+=("${_REG_TAGS[$j]}")
                done
                local remaining_str
                remaining_str=$(IFS=,; printf '%s' "${remaining[*]}")
                save_resume_state "$PROFILE" "$tag" "$remaining_str"
                printf '\n  %b✗ Failed at: %s%b\n' "$RED" "$tag" "$NC"
                printf '  %bResume state saved. Run with --resume to continue.%b\n' \
                    "$DIM" "$NC"
                return 1
            }
        done
    fi

    clear_resume_state
}

# ── Banner ────────────────────────────────────────────
banner() {
    printf '\n'
    printf '%b' "$BOLD"
    cat <<'EOF'
       __      __  _____ __
  ____/ /___  / /_/ __(_) /__  _____
 / __  / __ \/ __/ /_/ / / _ \/ ___/
/ /_/ / /_/ / /_/ __/ / /  __(__  )
\__,_/\____/\__/_/ /_/_/\___/____/
EOF
    printf '%b\n' "$NC"
}

# ── Main ──────────────────────────────────────────────
main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --resume)  RESUME_MODE=1; shift ;;
            --profile) PROFILE="$2"; shift 2 ;;
            *)         shift ;;
        esac
    done

    banner

    detect_os
    detect_profile

    # Handle resume mode
    if [[ "$RESUME_MODE" == "1" ]]; then
        . "$DOTFILES_DIR/lib/core.sh"
        . "$DOTFILES_DIR/lib/config.sh"
        . "$DOTFILES_DIR/lib/module.sh"

        if ! load_resume_state; then
            fail "No resume state found. Run install.sh normally first."
        fi

        step "Resuming"
        info "OS: $OS  Profile: $PROFILE  Failed at: $FAILED_TAG  Tags: $TAGS"

        step "Sudo"
        acquire_sudo

        step "Modules (resumed)"
        export DOTFILES_DIR OS PROFILE
        load_config
        load_registry
        run_modules_by_tags "$TAGS"
        clear_resume_state

        step "Done!"
        success "Dotfiles setup complete"
        info "Run 'dotfiles' for interactive management"
        printf '\n'
        return 0
    fi

    step "Environment"
    info "OS: $OS  Profile: $PROFILE  Target: $DOTFILES_DIR"

    step "Sudo"
    acquire_sudo

    step "Prerequisites"
    case "$OS" in
        macos)
            install_xcode_clt
            install_homebrew
            ;;
        *)
            install_git_linux
            ;;
    esac

    step "Dotfiles"
    clone_dotfiles

    step "Modules"
    run_dotfiles

    step "Done!"
    success "Dotfiles setup complete"
    info "Run 'dotfiles' for interactive management"
    printf '\n'
}

main "$@"
