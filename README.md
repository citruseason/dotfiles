# dotfiles

[@citruseason]'s dotfiles, powered by [Ansible].

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/citruseason/dotfiles/master/install.sh | bash
```

Supports **macOS**, **Ubuntu**, and **WSL**. OS and profile are auto-detected.

### Options

```bash
# Specify profile
curl -fsSL https://raw.githubusercontent.com/citruseason/dotfiles/master/install.sh | PROFILE=work bash

# Custom install path
curl -fsSL https://raw.githubusercontent.com/citruseason/dotfiles/master/install.sh | DOTFILES_DIR=~/my-dotfiles bash
```

## Manual Setup

```bash
git clone https://github.com/citruseason/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run with Make
make personal   # macOS (personal)
make work       # macOS (work)
make ubuntu     # Ubuntu
make wsl        # WSL

# Or use the interactive TUI
dotfiles
```

## Structure

```
roles/
├── common/          # Cross-platform
│   ├── fonts/       # D2Coding font family
│   ├── git/         # Git config, aliases, gitignore
│   ├── zsh/         # Zsh, plugins, Starship prompt
│   ├── mise/        # Runtime versions (Node, Python, Java, Ruby)
│   ├── apps/        # Ghostty terminal config
│   └── dotfiles_cli/# dotfiles CLI setup
├── macos/           # macOS only
│   ├── xcode/       # Xcode Command Line Tools
│   ├── homebrew/    # Homebrew packages (common + private)
│   ├── defaults/    # System preferences, app defaults
│   └── dock/        # Dock layout
├── linux/           # Linux common
│   └── apt/         # Essential apt packages
└── wsl/             # WSL only
    └── wsl/         # systemd, 1Password SSH, color aliases
```

## `dotfiles` CLI

After installation, the `dotfiles` command is available:

```bash
dotfiles            # Interactive TUI (role selector)
dotfiles --all      # Run all roles
dotfiles --tags git,zsh  # Run specific roles
dotfiles --help     # Show help
```

### TUI Controls

| Key | Action |
|-----|--------|
| `↑↓` / `jk` | Navigate |
| `Space` | Toggle selection |
| `a` | Select / deselect all |
| `Enter` | Run selected roles |
| `q` | Quit |

## Profiles

| Profile | Inventory | Description |
|---------|-----------|-------------|
| `personal` | macOS + personal apps (1Password, Karabiner, ...) | Default on macOS |
| `work` | macOS + common packages only | |
| `ubuntu` | Linux + apt packages | Default on Linux |
| `wsl` | Linux + WSL config (systemd, 1Password SSH) | Default on WSL |

[@citruseason]: https://github.com/citruseason
[Ansible]: https://www.ansible.com
