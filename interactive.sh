#!/bin/sh

#### Interactive config for all POSIX-compliant shells.
# This file sets up the minimum interactive environment I want on all shells (a
# couple of essential functions, some aliases, and a few macOS-specific things),
# then loads shell-specific config.
#
# (As this file is loaded by all shells, it's entirely POSIX-compliant.)
#
# This file's intended to be loaded after `env.sh`, as it also does some setup,
# namely setting `$SampShell_ROOTDIR`. This file expects that to be set, as it
# uses that to determine where the shell-specific config is located; If it's not
# set, the "universal config" in this file will still be run, but shell-specific
# configs won't be (as they can't be located).
####

if [ -n "${SampShell_interactive_loaded+1}" ]; then
	return 0
fi
SampShell_interactive_loaded=1

################################################################################
#                                                                              #
#                          Common Functions & Aliases                          #
#                                                                              #
################################################################################

## Short helper for looking at history.
# If any arguments are given, they're forwarded to `fc -l` (ie list that many
# arguments). Without arguments, if not connected to a tty, all commands are
# printed out (for usage with `grep`).
h () {
	if [ "$#" -eq 0 ] && [ ! -t 1 ]
	then set -- -n 0
	fi

	fc -l "$@"
}

## Changes to the directory containing its argument.
# (Useful for dragging files in from Finder to Terminal on MacOS.)
cdd () {
	if [ "$#" -ne 1 ]; then
		echo >&2 'usage: cdd path'
		echo >&2
		echo >&2 "cd's to the directory containing 'path'"
		return 2
	fi

	# We have to do this whole rigmarole in case the directory ends in a
	# newline. (Odd, but a possibility, and I don't want to be blindsided by
	# it later.)
	if ! SampShell_scratch=$(dirname -- "$1" && printf x); then
		unset -v SampShell_scratch
		return 1
	else
		set -- "${SampShell_scratch%?x}"
		unset -v SampShell_scratch # Unset the variable so it won't leak
	fi

	# In case the directory's name is `-`, we don't want to `cd -` (which
	# would be the previous directory.)
	[ "$1" = - ] && set ./-

	# Don't respect `CDPATH` here, as we know the directory to go to. Also,
	# don't use any aliases for `cd` in case they were defined.
	CDPATH= \cd -- "$1"
}

## Add in a `p` program which prints out a debugging form of its arguments.
# This program `.`s the `p` program, instead of being an alias or something, as
# that way variables with `NUL` in them can be passed in.
p () (
	. p
)

## Creates a directory, and then changes to it. (`rd` is a `bin-macOS` command.)
md () {
	# (use `\cd` so that we don't get alias expansion that might exist)
	mkdir -p -- "${1:?missing dir}" && CDPATH= \cd -- "$1"
}

## Common aliases
alias ls='ls -AFq'
alias l=ls
alias ll='l -l'
alias j=jobs

## Sublime Text editor shorthand aliases
alias s=subl
alias ss=ssubl
alias ssubl='subl --create'

################################################################################
#                                                                              #
#                                 STTY Setup                                   #
#                                                                              #
################################################################################

## TODO: IDK IF I WANT THIS
if [ -n "${SampShell_EXPERIMENTAL-}" ]; then
	[ -t 0 ] && stty noflsh
fi

################################################################################
#                                                                              #
#                                    Safety                                    #
#                                                                              #
################################################################################

## Don't clobber files on output
set -o noclobber

## Make `rm`, `mv`, and `cp` safe by default; repeat the second arg for unsafe
alias rm='rm -i'
alias rmm='command rm'

alias mv='mv -i'
alias mvv='command mv'

alias cp='cp -i'
alias cpp='command cp'

## Shorthand aliases for "safe alternatives" foundin `bin`
alias m=mv-safe
alias r=trash

################################################################################
#                                                                              #
#                                 MacOS Config                                 #
#                                                                              #
################################################################################

if [ "$(uname)" = Darwin ]; then
	## Add options to `ls` which macOS supports. (We only add the alias if
	# `ls` was already an alias, otherwise the `eval` doesn't work.)
	alias ls='ls -AFqhGb'
fi

################################################################################
#                                                                              #
#                                 CDPATH Setup                                 #
#                                                                              #
################################################################################
if [ -n "$SampShell_CDPATH" ]; then
	CDPATH=:$SampShell_CDPATH${CDPATH:+:}${CDPATH#:}
fi
