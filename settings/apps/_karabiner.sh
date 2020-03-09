#!/usr/bin/env bash

DIR_CONFIG=$HOME/.config
DIR_SETTINGS_KARA=$DOTHOME/settings/apps/karabiner

cp -r $DIR_SETTINGS_KARA $DOTCDIR
rm -rf $DIR_CONFIG/karabiner
ln -s $DOTCDIR/karabiner $DIR_CONFIG
launchctl kickstart -k gui/`id -u`/org.pqrs.karabiner.karabiner_console_user_server

