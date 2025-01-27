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
. "$SampShell_ROOTDIR/posix/min.sh" || return

h () if [ "$#" -eq 0 ] && [ ! -t 1 ]
     then fc -ln 0
     else fc -l "$@"
     fi


cdd () {
   if [ "$#" -ne 1 ]; then
      echo >&2 'usage: cdd file'
      echo >&2
      echo >&2 "CD's to the directory containing 'file'"
      return 2
   fi

   SampShell_scratch=$(dirname -- "$1" && printf x) || {
      unset -v SampShell_scratch
      return 1
   }
   set -- "${SampShell_scratch%?x}"
   unset -v SampShell_scratch
   [ "$1" = - ] && set -- ./-
   CDPATH= cd -- "$1"
}

## Interactive utils
nargs () { echo "$#"; }
p () {
   SampShell_scratch=0

   while [ "$#" != 0 ]; do
      SampShell_scratch=$((SampShell_scratch + 1))
      printf '%3d: %s\n' "$SampShell_scratch" "$1"
      shift
   done

   unset -v SampShell_scratch
}

alias ls='ls -AFq'
alias l='ls -l'

md () {
	# ZSH doesn't like `command cd` to get around aliasing; You could just
	# test for `ZSH_VERSION` and set `setopt LOCAL_OPTIONS POSIX_BUILTINS`,
	# but that's overkill and a simple backslash to attempt alias
	# suppression works fine.
	\mkdir -p -- "${1:?missing a directory}" && CDPATH= \cd -- "$1"
}

export SampShell_WORDS="${SampShell_WORDS:-/usr/share/dict/words}"
[ -z "$words" ] && export words="$SampShell_WORDS" # Only set `words` if it doesnt exist

################################################################################
#                                    Safety                                    #
################################################################################
set -o noclobber
alias rm='rm -i'  mv='mv -i'  cp='cp -i'
alias rmm='rm -f' mvv='mv -f' cpp='cp -f'

################################################################################
#                                    macOS                                     #
################################################################################
if [ "$(uname)" = Darwin ]; then
	eval "$(alias -L ls)hGb"
	pbc () if [ "$#" -eq 0 ]; then
		pbcopy
	else
		(unset IFS; echo "$*" | pbcopy)
	fi
	alias pbp=pbpaste
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
