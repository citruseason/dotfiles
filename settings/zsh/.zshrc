function command_exists() {
  hash "$1" &> /dev/null
}

if command_exists brew; then
    source $(brew --prefix)/share/antigen/antigen.zsh
else
    source /usr/local/share/antigen/antigen.zsh
fi

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle git
antigen bundle git-extras
antigen bundle git-flow
antigen bundle python
antigen bundle pip
antigen bundle node
antigen bundle npm
antigen bundle command-not-found

# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting

# Load the pure theme.
antigen bundle mafredri/zsh-async
antigen bundle denysdovhan/spaceship-prompt 

# Tell Antigen that you're done.
antigen apply

source ~/.aliases
