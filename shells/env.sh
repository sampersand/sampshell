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
#                 Enable xtrace if $SampShell_XTRACE is enabled                #
#                                                                              #
################################################################################

if [ -n "${SampShell_XTRACE-}" ]; then
	export SampShell_XTRACE # Export it in case it's not already exported.
	set -x
fi

if [ -n "${ZSH_VERSION-}" ]; then
	eval '. "${SampShell_ROOTDIR-${0:P:h}}/zsh/zshenv"'
	return
fi
