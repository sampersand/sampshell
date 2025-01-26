#### Basic config universal to _all_ POSIX-compliant shells
# This file should be `.`'d by both interactive and non-interactive shells.
# However, interactive shells should also `.` the `interactive` file as well,
# after this one.
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
# Since this is the entry point for _all_ shells, it must be kept pristine and
# strictly POSIX-compliant. Additionally, since it's expected that this file
# might also be sourced from within a script at any point, options such as
# `set -o nounset` must also be respected.
#
#
# $SampShell_ROOTDIR
# ==================
# As there's no way in POSIX to get the location of a `.`'d file within it, this
# script expects that `SampShell_ROOTDIR` is set prior to invocation, and is set
# to the folder that encloses this file. tl;dr, in the `~/.whatever`` file, put:
#
#   SampShell_ROOTDIR=/some/path/to/sampshell
#   . "$SampShell_ROOTDIR/env.sh"
#
# If `$SampShell_ROOTDIR` is not set, and we're not in an interactive shell (ie
# `$-` doesn't contain `i`), then the script simply returns `1`. Otherwise, it
# defaults to `$HOME/.sampshell` and emits a warning.
#
# Some shells (currently just ZSH and Bash) can omit `$SampShell_ROOTDIR`, and
# it'll be inferred by automatically to be the folder containing this file. If
# this is done, then no warnings are emitted and the file doesn't return early.
#
# If `$SampShell_ROOTDIR` isn't a directory (ie it points to a non-extant path,
# or to a file), then the script returns 2 (printing an error if we're in an
# interactive shell).
#
# If `$SampShell_ROOTDIR` is valid, then the rest of the script happens.
####


################################################################################
#                                                                              #
#                 Enable xtrace if $SampShell_TRACE is enabled                 #
#                                                                              #
################################################################################

if [ -n "${SampShell_TRACE-}" ]; then
	export SampShell_TRACE # Export it in case it's not already exported.
	set -x
fi

################################################################################
#                  Ensure $SampShell_ROOTDIR is set and valid                  #
################################################################################

### NOTE: IF THIS SECTION IS CHANGED, ALSO UPDATE `both.sh`!

# Make sure `SampShell_ROOTDIR` is set.
if [ -n "${SampShell_ROOTDIR-}" ]; then
	# Cool, it's already set. Nothing to do

elif [ -n "${ZSH_VERSION-}" ]; then
	# ZSH: just use the builtin `${0:P:h}` to find it
	# We need to use `eval` in case shells don't understand `${0:P:h}`.
	# (TODO: can you make this work with `emulate sh` in effect)
	eval 'SampShell_ROOTDIR="${0:P:h}"'

# BASH: Use `BASH_SOURCE`
elif [ -n "${BASH_SOURCE-}" ]; then
	SampShell_ROOTDIR=$(dirname -- "$BASH_SOURCE" && printf x) || return
	SampShell_ROOTDIR=${SampShell_ROOTDIR%?x}

# Non-interactive: Error, just return 1.
elif case $- in *i*) false; esac; then
	return 1

# We are interactive, default it and warn
else
	# Whelp, we can't rely on `$0`, let's just guess and hope?
	SampShell_ROOTDIR="$HOME/.sampshell"
	printf >&2 '[INFO] Defaulting $SampShell_ROOTDIR to %s\n' \
		"$SampShell_ROOTDIR" >&2
fi

# Make sure that it's actually a directory
if ! [ -d "$SampShell_ROOTDIR" ]; then
	# If we're interactive, then print out the warning
	if ! case $- in *i*) false; esac; then
		printf >&3 '[FATAL] Unable to initialize SampShell: $SampShell_ROOTDIR does not exist/isnt a dir: %s\n' \
			"$SampShell_ROOTDIR"
	fi

	return 2
fi

# Ensure `SampShell_ROOTDIR` is exported if it wasn't already.
export SampShell_ROOTDIR

################################################################################
#                                                                              #
#                          Other SampShell Variables                           #
#                                                                              #
################################################################################

: "${SampShell_gendir:=${SampShell_ROOTDIR:-${HOME:-/tmp}}}"
export SampShell_EDITOR="${SampShell_EDITOR:-sublime4}"
export SampShell_TRASHDIR="${SampShell_TRASHDIR:-$SampShell_gendir/.trash}"
export SampShell_HISTDIR="${SampShell_HISTDIR-$SampShell_gendir/.history}"
export HOMEBREW_NO_ANALYTICS=1

################################################################################
#                              Add SampShell bin                               #
################################################################################

# Add generic "SampShell" bin files to the start
case :${PATH-}: in
	*:"$SampShell_ROOTDIR/bin":*)
		# It's already there!
		:
		;;
	*)
		# Not present; prepend it.
		PATH=$SampShell_ROOTDIR/bin${PATH:+:}$PATH
		;;
esac

# Unconditionally add "experimental" binaries in, 'cause why not.
[ -z "${SampShell_no_experimental-}" ] && PATH="$SampShell_ROOTDIR/experimental:$PATH"

################################################################################
#                         Source Shell-Specific Config                         #
################################################################################

if [ -n "${ZSH_VERSION-}" ]; then
	. "$SampShell_ROOTDIR/zsh/zshenv"
	return
fi

# TODO: add more shell configs when i eventually need them, like bash
