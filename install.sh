#!/usr/bin/env bash

###########################
# 개인용 dotfiles 쓸사람은 써주세요~
###########################

if [ -f "$HOME/.padot" ]; then
  echo "Installed"
  exit
fi

source ./utils_sh/echos.sh
source ./utils_sh/brew_util.sh

print "Pavons-Dotfiles 설치를 시작합니다."

# Ask for the administrator password upfront
if sudo grep -q "# %wheel\tALL=(ALL) NOPASSWD: ALL" "/etc/sudoers"; then

  # Ask for the administrator password upfront
  print "설치를 하기위해서 sudo 비밀번호가 필요합니다.\npassword:"
  sudo -v

  # Keep-alive: update existing sudo time stamp until the script has finished
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

  print "제공받은 비밀번호를 어디다 활용하지는지 궁금하시다면 아래 URL를 확인해주세요.\n이것을 보고 활용하고있습니다.\nhttp://wiki.summercode.com/sudo_without_a_password_in_mac_os_x \n"

  read -r -p "앞으로 sudo 비밀번호 입력없이 상위권한에 접근하시길 원하십니까? [y|N] " response

  if [[ $response =~ (yes|y|Y) ]];then
      sed --version 2>&1 > /dev/null
      sudo sed -i '' 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers
      if [[ $? == 0 ]];then
          sudo sed -i 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers
      fi
      sudo dscl . append /Groups/wheel GroupMembership $(whoami)
      bot "지금부터 sudo 비밀번호는 자동으로 입력됩니다!"
  fi
fi

bot "gitconfig 셋팅"

while true; do
  read -r -p "git --global name: " name
  if [[ ! $name ]];then
    error "필수로 입력해주세요."
  else
    sed -i '' "s/GITNAME/$name/" ./configs/.gitconfig;
    break
  fi
done

while true; do
  read -r -p "gitconfig --global email: " email
  if [[ ! $email ]];then
    error "필수로 입력해주세요."
  else
    sed -i '' "s/GITEMAIL/$email/" ./configs/.gitconfig;
    break
  fi
done

while true; do
  read -r -p "Github username: " username
  if [[ ! $username ]];then
    error "필수로 입력해주세요."
  else
    sed -i '' "s/GITHUBUSER/$username/" ./configs/.gitconfig;
    break
  fi
done
ok

#####
# install homebrew (CLI Packages)
#####

running "homebrew 설치되어있는지 확인"
brew_bin=$(which brew) 2>&1 > /dev/null
if [[ $? != 0 ]]; then
  action "homebrew 설치를 시작합니다."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    if [[ $? != 0 ]]; then
      error "unable to install homebrew, script $0 abort!"
      exit 2
  fi
  ok
else
  ok
  # Make sure we’re using the latest Homebrew
  running "homebrew 업데이트"
  brew update
  ok

  echo
  read -r -p "brew 패키지에 대한 업그레이드를 시작할까요? [y|N] " response
  if [[ $response =~ ^(y|yes|Y) ]];then
      # Upgrade any already-installed formulae
      running "brew 페키지들을 업그레이드 하는중"
      brew upgrade
      ok
  else
      ok "\nbrew 업그레이드를 취소합니다.";
  fi
fi


#####
# install brew cask (UI Packages)
#####
running "brew-cask가 설치되어있는지 확인"
output=$(brew tap | grep cask)
if [[ $? != 0 ]]; then
  running "brew-cask 설치"
  require_brew caskroom/cask/brew-cask
fi
brew tap caskroom/versions > /dev/null 2>&1
ok

require_brew vim --override-system-vi
require_brew macvim
echo "alias vi='mvim -v'" >> configs/.zshrc
echo "alias vim='mvim -v'" >> configs/.zshrc
require_brew zsh

CURRENTSHELL=$(dscl . -read /Users/$USER UserShell | awk '{print $2}')
if [[ "$CURRENTSHELL" != "/usr/local/bin/zsh" ]]; then
  bot "zsh (/usr/local/bin/zsh) 셋팅을 시작합니다. (비밀번호 필요)"
  # sudo bash -c 'echo "/usr/local/bin/zsh" >> /etc/shells'
  # chsh -s /usr/local/bin/zsh
  sudo dscl . -change /Users/$USER UserShell $SHELL /usr/local/bin/zsh > /dev/null 2>&1
  ok
fi

if [[ ! -d "./oh-my-zsh/custom/themes/powerlevel9k" ]]; then
  git clone https://github.com/bhilburn/powerlevel9k.git oh-my-zsh/custom/themes/powerlevel9k
fi

bot "프로젝트 Config 심볼릭링크 처리"
pushd configs > /dev/null 2>&1
now=$(date +"%Y.%m.%d.%H.%M.%S")

for file in .*; do
  if [[ $file == "." || $file == ".." ]]; then
    continue
  fi

  running "~/$file"
  # if the file exists:
  if [[ -e ~/$file ]]; then
      if [[ $file != ".DS_Store" ]]; then
        mkdir -p ~/.dotfiles_backup/$now
        mv ~/$file ~/.dotfiles_backup/$now/$file
      fi
  fi
  # symlink might still exist
  unlink ~/$file > /dev/null 2>&1
  # create the link
  ln -s ~/.dotfiles/configs/$file ~/$file
  echo -en ' Linked';ok
done

popd > /dev/null 2>&1

require_brew cmake

echo
read -r -p "vim plugins 설치를 시작할까요? [y|N] " response
if [[ $response =~ ^(y|yes|Y) ]];then
    # Upgrade any already-installed formulae
    running "진행중 [주의! 시간이 많이걸림.] "
    vim +PluginInstall +qall > /dev/null 2>&1
    ok
    bot "YCM 설치"
    cd ~/.vim/bundle/YouCompleteMe && ./install.sh --clang-completer
    ok
fi

bot "fonts 설치"
./fonts/install.sh
ok

bot "Sequel Pro 설치 (SQL툴)"
require_cask sequel-pro
ok

bot "Cyberduck 설치 (FTP툴)"
require_cask cyberduck
ok

echo
read -r -p "pyenv, virtualenv, autoenv 설치? [y|N] " resp
if [[ $resp =~ ^(y|yes|Y) ]];then
    echo 'export PYENV_VIRTUALENV_DISABLE_PROMPT=1' >> ~/.zshrc
    require_brew pyenv
    echo 'eval "$(pyenv init -)"' >> ~/.zshrc

    require_brew pyenv-virtualenv
    echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.zshrc

    require_brew autoenv
    echo 'source /usr/local/opt/autoenv/activate.sh' >> ~/.zshrc

    require_brew gettext
    brew link gettext --force
fi

bot "iterm2 설치"
require_cask iterm2

bot "sublime-text 설치"
require_cask sublime-text

bot "sublime-text 설치"
require_cask sublime-text

bot "google-chrome 설치"
require_cask google-chrome-canary

########################
bot "iTerm2 settings"
########################

running "Installing the Solarized Dark theme for iTerm (opening file)"
open "./scheme/Solarized Dark.itermcolors";ok

running "Don’t display the annoying prompt when quitting iTerm"
defaults write com.googlecode.iterm2 PromptOnQuit -bool false;ok
running "hide tab title bars"
defaults write com.googlecode.iterm2 HideTab -bool true;ok
running "set system-wide hotkey to show/hide iterm with ^\`"
defaults write com.googlecode.iterm2 Hotkey -bool true;ok
running "hide pane titles in split panes"
defaults write com.googlecode.iterm2 ShowPaneTitles -bool false;ok
running "animate split-terminal dimming"
defaults write com.googlecode.iterm2 AnimateDimming -bool true;ok
defaults write com.googlecode.iterm2 HotkeyChar -int 96;
defaults write com.googlecode.iterm2 HotkeyCode -int 50;
defaults write com.googlecode.iterm2 FocusFollowsMouse -int 1;
defaults write com.googlecode.iterm2 HotkeyModifiers -int 262401;
running "Make iTerm2 load new tabs in the same directory"
/usr/libexec/PlistBuddy -c "set \"New Bookmarks\":0:\"Custom Directory\" Recycle" ~/Library/Preferences/com.googlecode.iterm2.plist
running "setting fonts"
defaults write com.googlecode.iterm2 "Normal Font" -string "D2Coding-Regular 12";
defaults write com.googlecode.iterm2 "Non Ascii Font" -string "RobotoMonoForPowerline-Regular 12";
ok
running "reading iterm settings"
defaults read -app iTerm > /dev/null 2>&1;
ok
