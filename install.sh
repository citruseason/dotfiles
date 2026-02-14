#!/bin/bash
set -euo pipefail

# ── Configuration (override via env vars) ─────────────
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/citruseason/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
PROFILE="${PROFILE:-}"

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

detect_inventory() {
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
    if xcode-select -p &>/dev/null; then
        success "Xcode CLT"
        return
    fi

    info "Installing Xcode Command Line Tools..."

    # Trigger softwareupdate catalog for CLT
    sudo touch /tmp/.com.apple.dt.CommandLineTools.done

    PROD=$(softwareupdate -l 2>&1 \
        | grep -E '^\s+\*.*Command Line Tools' \
        | sed 's/^[[:space:]]*\* Label: //' \
        | head -n 1)

    if [[ -n "$PROD" ]]; then
        sudo softwareupdate -i "$PROD" --verbose
    else
        # Fallback: trigger GUI dialog-based install (no sudo)
        xcode-select --install 2>/dev/null || true
        info "Waiting for Xcode CLT installation..."
        until xcode-select -p &>/dev/null; do sleep 5; done
    fi

    sudo rm -f /tmp/.com.apple.dt.CommandLineTools.done
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

    # Add brew to PATH for current session
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    success "Homebrew"
}

# ── Ansible ───────────────────────────────────────────
install_ansible_macos() {
    if has ansible-playbook; then
        success "Ansible"
    else
        info "Installing Ansible..."
        brew install ansible
        success "Ansible"
    fi

    # community.general collection (osx_defaults, etc.)
    if ansible-galaxy collection list 2>/dev/null | grep -q community.general; then
        success "community.general collection"
    else
        info "Installing Ansible community.general collection..."
        ansible-galaxy collection install community.general
        success "community.general collection"
    fi
}

install_ansible_linux() {
    if has ansible-playbook; then
        success "Ansible"
        return
    fi

    info "Installing Ansible..."
    if has apt-get; then
        sudo apt-get update -qq
        sudo apt-get install -y -qq software-properties-common
        sudo apt-add-repository -y --update ppa:ansible/ansible
        sudo apt-get install -y -qq ansible
    elif has dnf; then
        sudo dnf install -y ansible
    else
        # Fallback: pip
        sudo apt-get update -qq 2>/dev/null || true
        sudo apt-get install -y -qq python3 python3-pip 2>/dev/null || true
        pip3 install --user ansible
    fi
    success "Ansible"
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
        info "Updating dotfiles repo..."
        git -C "$DOTFILES_DIR" pull --rebase --quiet
        success "Dotfiles updated ($DOTFILES_DIR)"
    else
        info "Cloning dotfiles repo..."
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
        success "Dotfiles cloned ($DOTFILES_DIR)"
    fi
}

# ── Run Ansible Playbook ─────────────────────────────
run_playbook() {
    info "Running playbook: inventory/$PROFILE.yml"

    cd "$DOTFILES_DIR"

    ANSIBLE_CONFIG="$DOTFILES_DIR/ansible.cfg" \
    ansible-playbook "$DOTFILES_DIR/site.yml" \
        -i "$DOTFILES_DIR/inventory/${PROFILE}.yml"
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
    banner

    detect_os
    detect_inventory

    step "Environment"
    info "OS: $OS  Profile: $PROFILE  Target: $DOTFILES_DIR"

    step "Sudo"
    acquire_sudo

    step "Prerequisites"
    case "$OS" in
        macos)
            install_xcode_clt
            install_homebrew
            install_ansible_macos
            ;;
        *)
            install_git_linux
            install_ansible_linux
            ;;
    esac

    step "Dotfiles"
    clone_dotfiles

    step "Ansible Playbook"
    run_playbook

    step "Done!"
    success "Dotfiles setup complete"
    info "Run 'dotfiles' for interactive management"
    printf '\n'
}

main "$@"
