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
h ()	if [ "$#" -eq 0 ] && [ ! -t 1 ]
	then fc -ln 0
	else fc -l "$@"
	fi

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
	SampShell_scratch=$(dirname -- "$1" && printf x) || {
		unset -v SampShell_scratch
		return 1
	}
	set -- "${SampShell_scratch%?x}"
	unset -v SampShell_scratch # Delete the variable so it doesn't leak

	# In case the directory's name is `-`, we don't want to `cd -` (which
	# would be the previous directory.)
	[ "$1" = - ] && set -- ./-

	# Don't respect `CDPATH` here, as we know the directory to go to. Also,
	# don't use any aliases for `cd` in case they were defined.
	CDPATH= \cd -- "$1"
}

## Removes a directory
rd () {
	rmdir -- "$@"
}

## Creates a directory, and then changes to it.
md () {
	# (use `\cd` so that we don't get alias expansion that might exist)
	mkdir -p -- "${1:?missing dir}" && CDPATH= \cd -- "$1"
}

alias ls='ls -AFq'
alias l='ls -l'
alias j=jobs

if [ -n "${SampShell_EDITOR-}" ]; then
	alias s=subl ss=ssubl ssubl='subl --create'
fi

################################################################################
#                                                                              #
#                                    Safety                                    #
#                                                                              #
################################################################################

## Don't clobber files on output
set -o noclobber

## Make `rm`, `mv`, and `cp` safe by default; repeat the second arg for unsafe
alias rm='rm -i' rmm='command rm'
alias mv='mv -i' mvv='command mv'
alias cp='cp -i' cpp='command cp'

## Shorthand aliases for "safe alternatives" foundin `bin`
alias m=mv-safe
alias r=trash

################################################################################
#                                                                              #
#                                 MacOS Config                                 #
#                                                                              #
################################################################################

if [ "$(uname)" = Darwin ]; then
	## Copy its commands to the macOS clipboard. If not given any args,
	# instead read them from stdin.
	pbc ()	if [ "$#" -eq 0 ]
		then pbcopy
		else (unset -v IFS; printf %s "$*" | pbcopy)
		fi

	## Paste from macOS's clipboard
	alias pbp=pbpaste

	## Add options to `ls` which macOS supports. (We only add the alias if
	# `ls` was already an alias, otherwise the `eval` doesn't work.)
	if alias ls >/dev/null 2>&1; then
		eval "alias $([ -n "${BASH_VERSION-}" ] && set -o posix; alias ls)hGb"
	fi

	## Change the `rd` function to remove `.DS_Store` before doing `rmdir`.
	rd () {
		for SampShell_scratch; do
			## TODO: This will fail on `.DS_Store\n` filenames, but how likely is that?
			if [ .DS_Store = "$(command ls -A1q -- "$SampShell_scratch")" ]
			then
				command rm -f -- "$SampShell_scratch"/.DS_Store
			fi
		done
		unset -v SampShell_scratch
		command rmdir -- "$@"
	}
fi

################################################################################
#                                                                              #
#                         Source Shell-Specific Config                         #
#                                                                              #
################################################################################

if [ -n "${SampShell_EXPERIMENTAL-}" ] && [ -e "$SampShell_ROOTDIR/old-interactive.sh" ]
then
	. "$SampShell_ROOTDIR/old-interactive.sh"
fi

## Check to make sure `SampShell_ROOTDIR` is set, to provide a nicer error
# message than what `.` would output
if [ ! -n "${SampShell_ROOTDIR+1}" ]; then
	printf '[WARN] Cant init SampShell: SampShell_ROOTDIR not set\n' >&2
	return 0
elif [ ! -d "$SampShell_ROOTDIR" ]; then
	printf '[WARN] Cant init SampShell: SampShell_ROOTDIR not a dir: %s\n' \
		"$SampShell_ROOTDIR" >&2
	return 0
fi

# ZSH
if [ -n "${ZSH_VERSION-}" ]; then
	. "$SampShell_ROOTDIR/zsh/zshrc"
	return
fi

# Dash doesn't expose a nice variable like `ZSH_VERSION`, so we have to check
# `$0` and hope, lol.
case "$0" in dash | */dash)
	. "$SampShell_ROOTDIR/dash/.interactive.dash"
	return
esac
