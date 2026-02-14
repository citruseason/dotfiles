# Zsh plugins directory
ZSH_PLUGINS="$HOME/.zsh/plugins"

# Load plugins
[ -f "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
  source "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

[ -f "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
  source "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"

[ -f "$ZSH_PLUGINS/zsh-completions/zsh-completions.plugin.zsh" ] && \
  fpath=("$ZSH_PLUGINS/zsh-completions/src" $fpath)

# Completion system
autoload -Uz compinit && compinit

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt append_history
setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space

# Key bindings
bindkey -e

# Aliases
[ -f ~/.aliases ] && source ~/.aliases

# SSH agent
eval "$(ssh-agent -s)" &>/dev/null

# LS_COLORS (vivid)
if command -v vivid &>/dev/null; then
  export LS_COLORS="$(vivid generate snazzy)"
fi

# Starship prompt
eval "$(starship init zsh)"

# Load Ansible-managed extra configuration
[ -f ~/.zshrc_extra ] && source ~/.zshrc_extra
