#!/usr/bin/env bash

# Set source and target directories
CURRENT_DIR=$( cd "$( dirname "$0" )" && pwd )
DOTHOME="$( cd ${CURRENT_DIR}/../ && pwd )"
source $DOTHOME/command/echos.sh

find_command="find \"$CURRENT_DIR\" \( -name '*.[o,t]t[c,f]' -or -name '*.pcf.gz' \) -type f -print0"

if [[ `uname` == 'Darwin' ]]; then
  # MacOS
  font_dir="$HOME/Library/Fonts"
else
  # Linux
  font_dir="$HOME/.local/share/fonts"
  mkdir -p $font_dir
fi

# Copy all fonts to user fonts directory
running "Copying fonts..."
eval $find_command | xargs -0 -I % cp "%" "$font_dir/"
ok

# Reset font cache on Linux
if command -v fc-cache @>/dev/null ; then
    running "Resetting font cache, this may take a moment..."
    fc-cache -f $font_dir
    ok
fi

print "All Powerline fonts installed to $font_dir \n"
