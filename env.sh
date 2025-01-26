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
#                                                                              #
#                  Ensure $SampShell_ROOTDIR is set and valid                  #
#                                                                              #
################################################################################

### NOTE: IF THIS SECTION IS CHANGED, ALSO UPDATE `both.sh`!
if [ -n "${SampShell_ROOTDIR-}" ]; then
	# Already setup, nothing to do.
	:
elif [ -n "${ZSH_VERSION-}" ]; then
	# ZSH: just use the builtin `${0:P:h}` to find it
	SampShell_ROOTDIR=${0:P:h}
elif [ -n "${BASH_SOURCE-}" ]; then
	# BASH: Use `BASH_SOURCE` (the path to this file) to get it. We need to
	# use the `&& printf x` trick
	SampShell_ROOTDIR=$(dirname -- "$BASH_SOURCE" && printf x) || return
	SampShell_ROOTDIR=$(realpath -- "${SampShell_ROOTDIR%?x}" && printf x) || return
	SampShell_ROOTDIR=${SampShell_ROOTDIR%?x}
elif case $- in *i*) false; esac; then
	# Non-interactive: Error, just return 1.
	return 1
else
	# We are interactive, guess a default (hope it works) and warn.
	SampShell_ROOTDIR="$HOME/.sampshell"
	printf >&2 '[WARN] Defaulting $SampShell_ROOTDIR to %s\n' "$SampShell_ROOTDIR"
fi

# Make sure that `$SampShell_ROOTDIR` is actually a directory
if ! [ -d "$SampShell_ROOTDIR" ]; then
	# If we're interactive, then print out a warning
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
#                                                                              #
#                          Add SampShell bin to $PATH                          #
#                                                                              #
################################################################################

# Add it to the $PATH, but make sure it's not already there to begin with (to
# make our `$PATH` cleaner in case this file's run multiple times.)
case :${PATH-}: in
*:"$SampShell_ROOTDIR/bin":*)
	# Our bin already exists, nothing to do!
	: ;;
*)
	# It doesn't exist. Prepend it.
	PATH=$SampShell_ROOTDIR/bin${PATH:+:}$PATH

	# Issue a warning if the bin doesn't exist, and we're in an interactive
	# shell.
	if [ ! -d "$SampShell_ROOTDIR/bin" ] && ! case $- in *i*) false; esac; then
		printf '[WARN] SampShell bin dir cannot be found at: %s\n' "$SampShell_ROOTDIR/bin"
	fi

	;;
esac

# Unconditionally add "experimental" scripts in, 'cause why not.
[ -z "${SampShell_no_experimental-}" ] && PATH="$SampShell_ROOTDIR/experimental:$PATH"

################################################################################
#                                                                              #
#                         Source Shell-Specific Config                         #
#                                                                              #
################################################################################

if [ -n "${ZSH_VERSION-}" ]; then
	. "$SampShell_ROOTDIR/zsh/zshenv"
	return
fi

# TODO: add more shell configs when i eventually need them, like bash
