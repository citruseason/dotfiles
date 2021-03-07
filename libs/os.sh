#!/bin/bash

case $(uname | tr '[:upper:]' '[:lower:]') in
  linux*)
    export DOT_OS_NAME=linux
    ;;
  darwin*)
    export DOT_OS_NAME=osx

    UNAME_MACHINE="$(/usr/bin/uname -m)"
    if [[ "$UNAME_MACHINE" == "arm64" ]]; then
      # On ARM macOS
      export DOT_ON_ARM=1
    fi
    ;;
  msys*)
    export DOT_OS_NAME=windows
    ;;
  *)
    export DOT_OS_NAME=notset
    ;;
esac