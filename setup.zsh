#!/bin/zsh
emulate zsh

HOMEDIR=$PWD/deleteme-tmp.ignore
[[ $HOMEDIR = */deleteme-tmp.ignore ]] && {
	rm -r $HOMEDIR
	mkdir -p $HOMEDIR
}

>>$HOMEDIR/.irbrc <<'RUBY'
require 'bitint'
using BitInt
