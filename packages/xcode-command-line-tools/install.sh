#!/bin/bash

xcode_select="xcode-select --print-path"
xcode_install=$($xcode_select) 2>&1 >/dev/null
if [[ $? != 0 ]]; then
    xcode-select --install
fi
