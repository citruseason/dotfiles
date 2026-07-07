# Dotfiles

macOS, Linux, WSL, Windows를 지원하는 개인 dotfiles 관리 시스템.

## 프로젝트 상태

Ansible 기반에서 순수 shell script로 마이그레이션 완료.
마이그레이션 계획: `migrations/001-ansible-to-shell.md`

## 구조

- `install.sh` — Unix 부트스트랩 엔트리포인트 (macOS/Linux/WSL)
- `bin/dotfiles` — 대화형 TUI CLI
- `windows/setup.ps1` — Windows PowerShell 셋업
- `lib/` — 공유 셸 라이브러리
- `modules/` — 셸 모듈 시스템
- `modules/macos/homebrew/Brewfile`, `Brewfile.private` — macOS 패키지 목록 (brew bundle, private은 personal 프로필 전용)
- `config/` — 플랫폼/프로필 변수

## 규칙

- **Bash 3.2 호환 필수** (macOS 기본 bash)
  - `declare -A` (연관 배열) 사용 금지
  - `local -n` (nameref) 사용 금지
  - `readarray` / `mapfile` 사용 금지
- **BSD/GNU 호환**: `sed -i` 대신 `perl -i` 사용 (macOS BSD sed 비호환)
- **멱등성**: 모든 모듈은 여러 번 실행해도 안전해야 함
- **서브셸 실행**: 모듈은 서브셸에서 실행됨 — `exit`가 러너를 죽이지 않음
- **한국어**: 커밋 메시지, 문서는 한국어 사용

## 모듈 추가 방법

1. `modules/<os>/<name>/module.conf` 생성
2. `modules/<os>/<name>/install.sh` 작성
3. `modules/order.conf`에 경로 추가

## 테스트

- `dotfiles --tags <tag>` 로 개별 모듈 테스트
- `dotfiles --list` 로 모듈 상태 확인
- `dotfiles --help` 로 사용 가능한 모듈 목록 확인

## 주요 명령어

- `dotfiles` — TUI 모드
- `dotfiles --all` — 모든 모듈 실행
- `dotfiles --tags t1,t2` — 특정 모듈 실행
- `dotfiles --resume` — 실패 지점부터 재개
- `dotfiles --list` — 모듈 상태 확인
