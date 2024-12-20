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
#                  Ensure $SampShell_ROOTDIR is set and valid                  #
################################################################################

# Make sure `SampShell_ROOTDIR` is set.
if [ -z "${SampShell_ROOTDIR-}" ]; then
	# If we're using ZSH, just use the builtin `${0:P:h}` to find it.
	if [ -n "${ZSH_VERSION-}" ]; then
		# We need to use `eval` in case shells don't understand `${0:P:h}`.
		eval 'SampShell_ROOTDIR="${0:P:h}"'
	elif [ -n "${BASH_VERSION-}" ] && [ -n "${BASH_SOURCE-}" ]; then
		SampShell_ROOTDIR=$(dirname -- "$BASH_SOURCE" && printf x) || return
		SampShell_ROOTDIR=${SampShell_ROOTDIR#?x}

	# If we're not interactive, then just return 1
	elif case "$-" in *i*) false; esac; then
		return 1

	# We are interactive, default it and warn
	else
		# Whelp, we can't rely on `$0`, let's just guess and hope?
		SampShell_ROOTDIR="$HOME/.sampshell"
		printf '[INFO] Defaulting $SampShell_ROOTDIR to %s\n' \
			"$SampShell_ROOTDIR" >&2
	fi
fi

# Make sure that it's actually a directory
if ! [ -d "$SampShell_ROOTDIR" ]; then
	# If we're interactive, then print out the warning
	if ! case $- in *i*) false; esac; then
		printf '[FATAL] Unable to initialize SampShell: $SampShell_ROOTDIR does not exist/isnt a dir: %s\n' \
			"$SampShell_ROOTDIR" >&2
	fi

	return 2
fi

# Ensure `SampShell_ROOTDIR` is exported if it wasn't already.
export SampShell_ROOTDIR

################################################################################
#                        Source POSIX-Compliant Config                         #
################################################################################

# Note we don't check for whether the file exists; if it doesn't we're already
# done for...
. "$SampShell_ROOTDIR/posix/env.sh" || return

################################################################################
#                              Add SampShell bin                               #
################################################################################

# Add generic "SampShell" bin files in
export PATH="$SampShell_ROOTDIR/bin${PATH:+:}$PATH"

################################################################################
#                         Source Shell-Specific Config                         #
################################################################################

if [ -n "${ZSH_VERSION-}" ]; then
	. "$SampShell_ROOTDIR/zsh/env.zsh"
	return
fi

# TODO: add more shell configs when i eventually need them, like bash
