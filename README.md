# dotfiles

[@citruseason]'s dotfiles, powered by [Ansible].

## Quick Start

### macOS / Ubuntu / WSL

Default:

```bash
curl -fsSL https://raw.githubusercontent.com/citruseason/dotfiles/master/install.sh | bash
```

Work profile:

```bash
curl -fsSL https://raw.githubusercontent.com/citruseason/dotfiles/master/install.sh | PROFILE=work bash
```

OS and profile are auto-detected. Options:

```bash
# Specify profile
curl ... | PROFILE=work bash

# Custom install path
curl ... | DOTFILES_DIR=~/my-dotfiles bash
```

### Windows 11

Run as **Administrator** in PowerShell:

```powershell
irm https://raw.githubusercontent.com/citruseason/dotfiles/master/windows/setup.ps1 | iex
```

CDN 캐시 무효화 (테스트/변경 직후):

```powershell
irm "https://raw.githubusercontent.com/citruseason/dotfiles/master/windows/setup.ps1?$(Get-Date -Format 'yyyyMMddHHmmss')" | iex
```

항상 최신 스크립트를 원격에서 받아 실행합니다. 재실행해도 이미 설치된 항목은 건너뜁니다.

Installs PowerToys, 1Password, Tailscale, WSL+Ubuntu, Win11Debloat, and auto-detects CPU/GPU drivers.

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
│   ├── homebrew/    # Homebrew packages (common + private)
│   ├── defaults/    # System preferences, app defaults
│   └── dock/        # Dock layout
├── linux/           # Linux common
│   └── apt/         # Essential apt packages
└── wsl/             # WSL only
    └── wsl/         # systemd, 1Password SSH, color aliases

windows/
└── setup.ps1        # Windows 11 setup (PowerShell)
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

## Vorssaint 설정 백업·복원 (macOS)

`modules/macos/vorssaint/files/settings.plist`에 저장한 설정은 전체 설치 시
Homebrew 다음에 복원됩니다. 설정만 복원하려면 Vorssaint를 종료하고 실행합니다.

```bash
dotfiles --tags vorssaint
```

기존 설정은 `~/.local/state/dotfiles/backups/vorssaint/`에 매번 별도로 백업합니다.
`XDG_STATE_HOME`을 지정했다면 그 아래에 저장합니다. 앱이 실행 중이거나 백업에
실패하면 복원을 중단합니다. 복원 후 앱을 직접 실행하세요.

설정을 갱신하려면 Vorssaint 설정의 **Export Settings**로 내보낸 plist를
`modules/macos/vorssaint/files/settings.plist`에 저장하세요. 같은 파일을 앱의
**Import Settings**로 가져올 수도 있습니다. 내보내기에는 스니펫·메모가 포함될 수
있으니 커밋 전 변경 내용을 확인하세요.

최초 스냅샷은 이 Mac의 Vorssaint 3.3.2에 저장된 설정 중 공식 백업 대상만 담았습니다.
새 Mac에서 지정하지 않은 값은 설치된 앱의 기본값을 따릅니다. 파일 선반·클립보드 내용과
일시적인 실행 상태는 제외했습니다. 복원은 저장된 항목을 덮어쓰고 나머지 기존 설정은
유지합니다. macOS 접근성·화면 기록 권한과 로그인 시 실행 등록은 대상 Mac에서 확인해야 합니다.

복원 전 설정으로 되돌리려면 앱을 종료한 상태에서 실행합니다.

```bash
defaults delete com.vorssaint.utils
defaults import com.vorssaint.utils /path/to/settings.backup.plist
```

검증: `/bin/bash tests/vorssaint.sh` (실제 앱 설정은 변경하지 않습니다).

## Profiles

| Profile | Inventory | Description |
|---------|-----------|-------------|
| `personal` | macOS + personal apps (1Password, Karabiner, ...) | Default on macOS |
| `work` | macOS + common packages only | |
| `ubuntu` | Linux + apt packages | Default on Linux |
| `wsl` | Linux + WSL config (systemd, 1Password SSH) | Default on WSL |

[@citruseason]: https://github.com/citruseason
[Ansible]: https://www.ansible.com
