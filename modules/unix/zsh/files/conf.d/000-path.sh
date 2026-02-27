# Dotfiles environment
export DOTHOME="$HOME/dotfiles"
export PATH="$HOME/.local/bin:$DOTHOME/bin:$PATH"

# Aliases
[ -f ~/.aliases ] && source ~/.aliases
[ -f ~/.aliases_platform ] && source ~/.aliases_platform
