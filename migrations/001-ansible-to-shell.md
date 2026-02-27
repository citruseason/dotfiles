# Migration 001: Ansible → Pure Shell Scripts

## 동기

- 새 머신 셋업 시 Ansible 설치가 선행되어야 함
- 단순 파일 복사/패키지 설치에 비해 Ansible 구조가 과중함
- 순수 shell script로 전환하여 의존성 제거

## 핵심 설계 결정

1. **OS별 모듈 폴더**: `modules/unix/`, `modules/macos/`, `modules/linux/`, `modules/wsl-ubuntu/`
2. **Unix 공용 모듈**: `modules/unix/` — macOS/Linux/WSL 공유, TUI에서 "Shared"로 표시
3. **Per-module manifest**: 각 모듈에 `module.conf` 파일, 실행 순서는 `modules/order.conf`
4. **서브셸 실행**: 모듈은 서브셸에서 실행, `exit`가 러너를 죽이지 않도록 격리
5. **Brewfile**: `brew bundle` 대신 직접 설치 (기존 방식 유지)
6. **Bash 3.2 호환**: `declare -A`, `local -n`, `readarray` 사용 금지
7. **Shell 연동 분리 (conf.d)**: 각 모듈이 자신의 shell integration snippet 제공
8. **Windows**: monolithic `setup.ps1` 유지, `-Tags` 파라미터 추가
9. **태그 하위호환**: `cli` → `dotfiles-cli`, `macos` → `macos-defaults` alias 지원

## conf.d 패턴

`~/.config/shell/conf.d/` 디렉토리에 번호 기반 shell snippet 배치:
- `000-099` 기본 환경 (PATH, DOTHOME, aliases)
- `100-199` 패키지 매니저 (brew, mise)
- `200-299` 셸 통합 (starship, vivid, dircolors)
- `900-999` 오버라이드 / 로컬

## 삭제된 파일

- `site.yml`, `ansible.cfg`
- `inventory/` (전체)
- `group_vars/` (전체)
- `roles/` (전체)
- `packages/homebrew/`

## 완료일

2026-02-27
