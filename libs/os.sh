#!/bin/bash

case $(uname | tr '[:upper:]' '[:lower:]') in
  linux*)
    export DOT_OS_NAME=linux
    ;;
  darwin*)
    export DOT_OS_NAME=osx
    ;;
  msys*)
    export DOT_OS_NAME=windows
    ;;
  *)
    export DOT_OS_NAME=notset
    ;;
esac