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
#                        Source POSIX-Compliant Config                         #
################################################################################

# Note we don't check for whether the file exists; if it doesn't we're already
# done for, so we might as well just error out. 
. "$SampShell_ROOTDIR/posix/interactive.sh" || return

################################################################################
#                         Source Shell-Specific Config                         #
################################################################################

# ZSH
if [ -n "${ZSH_VERSION-}" ]; then
	. "$SampShell_ROOTDIR/zsh/interactive.zsh"
	return
fi

# Dash doesn't expose a nice variable like `ZSH_VERSION`, so we have to check
# `$0` and hope, lol.
case "$0" in dash | */dash)
	. "$SampShell_ROOTDIR/dash/interactive.dash"
	return
esac

# NOTE: We don't disable xtrace/verbose here, in case the `.zshrc` or whatnot
# wants to xtrace their own things too.
