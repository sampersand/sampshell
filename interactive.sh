#### Basic config universal to _all_ interactive POSIX-compliant shells
# Interactive shells should `.` this file after `.`ing the `env.sh` file, as
# that contains key definitions (such as `$SampShell_ROOTDIR`, updating `$PATH`,
# etc.)
#
#
# Overview
# ========
# This file does the following things:
# 1. Check for `$SampShell_ROOTDIR` (see below
# 2. Load the universal config for all POSIX-compliant shells
# 3. Load shell-specific config
#
#
# POSIX-compliant
# ===============
# Since this is the entry point for _all_ interactive shells, it must be kept
# pristine and strictly POSIX-compliant. However, unlike `env.sh`, it's not
# expected that this file will be sourced at any point, so options like the
# `set -o nounset` don't need to be respected.
###

# At this point, we can assume the `env.sh` file has been run, and as such that
# `$SampShell_ROOTDIR` exists, is exported, and is an actual directory. But,
# let's just check for sanity's sake.
[ -n "$SampShell_ROOTDIR" ] || return 1
[ -d "$SampShell_ROOTDIR" ] || return 2

################################################################################
#                                                                              #
#                             SampShell Functions                              #
#                                                                              #
################################################################################

## Short helper for looking at history.
# If any arguments are given, they're forwarded to `fc -l` (ie list that many
# arguments). Without arguments, if not connected to a tty, all commands are
# printed out (for usage with `grep`).
h () {
	if [ "$#" -eq 0 ] && [ ! -t 1 ]; then
		fc -ln 0
	else
		fc -l "$@"
	fi
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
	SampShell_scratch=$(dirname -- "$1" && printf x) || {
		unset -v SampShell_scratch
		return 1
	}
	set -- "${SampShell_scratch%?x}"
	unset -v SampShell_scratch # Delete the variable so it doesn't leak

	# In case the directory's name is `-`, we don't want to `cd -` (which
	# would be the previous directory.)
	[ "$1" = - ] && set -- ./-

	# IF `ZSH` is set
	if [ -n "$ZSH_VERSION" ]; then
		setopt LOCAL_OPTIONS POSIX_BUILTINS
	fi

	# Don't respect `CDPATH` here, as we know the directory to go to. Also,
	# use `\` to disable alias expansion for `cd`. (We could use `command`,
	# but `zsh`)
	CDPATH= \cd -- "$1"
}

## Simply prints out how many args were given to the function
nargs () {
	echo "$#"
}

## Prints out its arguments in a debug format.
p () {
	SampShell_scratch=0

	while [ "$#" != 0 ]; do
		printf '%3d: %q\n' "$((SampShell_scratch += 1))" "$1"
		shift
	done

	unset -v SampShell_scratch
}

## Creates a directory, and then changes to it.
md () {
	# (ZSH by default doesn't like `command cd` to get around aliasing, so
	# we have to convince it to do it by setting `POSIX_BUILTINS`.)
	if [ -n "$ZSH_VERSION" ]; then
		setopt LOCAL_OPTIONS POSIX_BUILTINS
	fi

	command mkdir -p -- "${1:?missing dir}" && CDPATH= command cd -- "$1"
}

## Add in custom flags to `ls`; We make it a function so that the macOS config
# can add in an alias later on to add additional default flags.
unalias ls >/dev/null 2>&1 # Remove the alias in case it already existed
ls () {
	command ls -AFq "$@"
}
alias l='ls -l'
alias j=jobs


export SampShell_WORDS="${SampShell_WORDS:-/usr/share/dict/words}"
[ -z "$words" ] && export words="$SampShell_WORDS" # Only set `words` if it doesnt exist

if [ -n "$SampShell_EDITOR" ]; then
	alias s=subl ss=ssubl ssubl='subl --create'
fi


################################################################################
#                                    Safety                                    #
################################################################################
set -o noclobber
alias  rm='rm -i'  mv='mv -i'  cp='cp -i'
alias rmm='rm -f' mvv='mv -f' cpp='cp -f'

# Alias for `bin` things.
alias m=mv-safe r=trash

################################################################################
#                                    macOS                                     #
################################################################################
if [ "$(uname)" = Darwin ]; then
	pbc () if [ "$#" -eq 0 ]; then
		pbcopy
	else
		(unset -v IFS; printf %s "$*" | pbcopy)
	fi
	alias pbp=pbpaste
	alias ls='ls -hGb' # MACOS-specific ls
fi


################################################################################
#                         Source Shell-Specific Config                         #
################################################################################

# ZSH
if [ -n "${ZSH_VERSION-}" ]; then
	. "$SampShell_ROOTDIR/zsh/zshrc"
	return
fi

# Dash doesn't expose a nice variable like `ZSH_VERSION`, so we have to check
# `$0` and hope, lol.
case "$0" in dash | */dash)
	. "$SampShell_ROOTDIR/dash/profile.dash"
	return
esac

# NOTE: We don't disable xtrace/verbose here, in case the `.zshrc` or whatnot
# wants to xtrace their own things too.
