#!/usr/bin/env bash

# Set source and target directories
CURDIR=$( cd "$( dirname "$0" )" && pwd )

find_command="find \"$CURDIR\" \( -name '*.[o,t]t[c,f]' -or -name '*.pcf.gz' \) -type f -print0"

if [[ `uname` == 'Darwin' ]]; then
  # macOS
  font_dir="$HOME/Library/Fonts"
else
  # Linux
  font_dir="$HOME/.local/share/fonts"
  mkdir -p $font_dir
fi

# Copy all fonts to user fonts directory
eval $find_command | xargs -0 -I % cp "%" "$font_dir/"

# Reset font cache on Linux
if command -v fc-cache @>/dev/null ; then
    fc-cache -f $font_dir
fi
