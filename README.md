# dotfiles

[@relomote]' dotfiles.

## Requirements

- [Git]

## Installation

Clone(or Download) this repository:

```sh
$ git clone https://github.com/pavons/dotfiles.git ~/dotfiles
```

Install this dotfiles:

```sh
# private
$ cd ~/dotfiles && ./install.sh

# work device
$ cd ~/dotfiles && ./work.install.sh
```

First-Time git setup (options):

```sh
$ git config --global user.name "{{ Your name }}"
$ git config --global user.email {{ Your email }}
```

## 참고

알아두면 좋은 맥북 시스템 설정

### RME 드라이버 설치

[RME 드라이버 설치](https://helpsound.net/bbs/board.php?bo_table=ASfaq&wr_id=114&page=1)를 진행해줍니다. <br />
그리고 나서 아래와 같이 진행합니다.

```
# 1. 복구모드 진입
# [m1 mac] - 맥북의 전원을 끈 상태에서 전원 버튼을 계속 누르고 있으면 복구 모드로 진입할 수 있습니다.

# 2. 유틸리티 > 터미널에서 아래 커맨드 입력
$ csrutil disable

# 3. 재부팅
```

[@relomote]: https://github.com/relomote
[git]: http://git-scm.com
