#!/bin/bash
# modules/wsl-ubuntu/wsl-ubuntu-setup/install.sh — WSL Ubuntu 전용 설정

# ── systemd 활성화 ──
info "Enabling systemd in WSL..."
sudo tee /etc/wsl.conf > /dev/null << 'CONF'
# BEGIN DOTFILES MANAGED - WSL boot config
[boot]
systemd=true
# END DOTFILES MANAGED - WSL boot config
CONF
success "WSL systemd"

# ── 1Password SSH agent ──
info "Configuring SSH for 1Password agent..."

ensure_dir "$HOME/.ssh"
chmod 0700 "$HOME/.ssh"

inject_block "$HOME/.ssh/config" "DOTFILES - 1Password SSH agent" \
"Host *
    IdentityAgent ~/.1password/agent.sock"
chmod 0600 "$HOME/.ssh/config"

inject_block "$HOME/.zshrc" "DOTFILES - 1Password SSH agent" \
'export SSH_AUTH_SOCK=~/.1password/agent.sock'

# git SSH override 제거
git config --global --unset core.sshCommand 2>/dev/null || true
success "1Password SSH agent"

# ── 컬러 alias ──
inject_block "$HOME/.zshrc" "DOTFILES - WSL color aliases" \
'# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='"'"'ls --color=auto'"'"'
    alias grep='"'"'grep --color=auto'"'"'
    alias fgrep='"'"'fgrep --color=auto'"'"'
    alias egrep='"'"'egrep --color=auto'"'"'
fi'
success "WSL color aliases"
