# Path to your oh-my-zsh installation.
export ZSH=$HOME/.dotfiles/oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
ZSH_THEME="powerlevel9k/powerlevel9k"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
plugins=(git)

source $ZSH/oh-my-zsh.sh

# Powerlevel9k Settings
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status virtualenv dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(time)
POWERLEVEL9K_STATUS_VERBOSE=false

POWERLEVEL9K_VIRTUALENV_FOREGROUND='black'
POWERLEVEL9K_VIRTUALENV_BACKGROUND='white'

# User configuration
alias zshconfig="vi ~/.zshrc"
alias ohmyzsh="vi ~/.oh-my-zsh"

