#### POSIX-compliant SampShell definitions for both scripts and interactive shells.
# This file is designed to be `.`able from nearly anywhere, including at the top
# of all POSIX-compliant shell scripts (including ones I haven't written), as
# it introduces important definitions (such as `$PATH`, or `$SampShell_EDITOR`)
# that should always be present.
#
# Technically this relies on `$HOME` for `SampShell_gendir`
#
# Because of this, this file is strictly POSIX-compliant.
#
# The environment variables here are also so if a process spawns another proc
# which spawns a shell, we'll keep soem of the sme functionality
#
# Order of Operations
# ===================
#   1. Create `Sampshell_XXX` variables (if they dont exist), and export them.
#   2. Setup `SampShell_xxx functions.
#   3. If `$SampShell_ROOTDIR` is set, add POSIX-compliant utilites to `$PATH`.
#   4. If `$SampShell_TRACE` is set, enable `xtrace` and `verbose`.
#
#
# Required Variables
# ==================
# This script makes no assumptions about what variables are present. When
# creating `SampShell_XXX` variables, unset (and empty for some; see their
# definitions) variables are populated with a default value.
#
# The `$SampShell_ROOTDIR` variable is not set by this script. If it was set
# before this script, it is used for adding POSIX-compliant utilites to `$PATH`
#
#
# Safety
# ======
# Since this is intended to be `.`able from within scripts, numerous safe
# been done:
#
#   * All variables and functions are prefixed with `SampShell_` to prevent
#     naming collisions.
#   * No `alias`es are added.
#   * The `set -eux` options from POSIX are respected, in case they're present
#
# Additionally, to make it easy to transfer this file around, and paste it
# directly into terminals, some other things are done:
#
#   * Line-continuation (`\` at the end of a line) is never done.
#   * Lines are limited to 80 characters when possible
#   * Only spaces are used for indentation (makes it easy to copy-paste)
####

################################################################################
#                            Environment Variables                             #
################################################################################

# Note: We always export these variables, so that they're visible from scripts
# too. (Also, `PATH` is set at the very end of this file)
#
# NOTE: These variables allhave default values. some variables will default on
# both unset and empty, and some will only default on unset.

## Whether to log SampShell diagnostic information.
# (Diagnostic information is logged if `$SampShell_VERBOSE` is a nonempty value)
#
# This defaults to enabled only in interactive shells. However unlike most other
# variables, this default is only used if `$SampShell_VERBOSE` is unset---if it
# is set to the empty value, it's kept that way.
if [ -z "${SampShell_VERBOSE+1}" ]; then
   # `$-` is a string of single-char options in POSIX shells; `i` is interactive
   case "$-" in
      *i*) SampShell_VERBOSE=1 ;;
      *)   SampShell_VERBOSE=  ;;
   esac
fi
export SampShell_VERBOSE

## The editor to open files with via the `subl` command
# This is exported so that applications like `irb` can run `subl`.
export SampShell_EDITOR="${SampShell_EDITOR:-sublime4}"

## Where all files that SampShell uses should by default be placed at.
# This is only used to set default values for the `SampShell_*DIR` variables, so
# it's not exported (child processes don't care about how defaults were set).
: "${SampShell_gendir:=${SampShell_ROOTDIR:-${HOME:-/tmp}}}"

## The default trash folder for the `trash` command (found in `posix/bin/trash`)
export SampShell_TRASHDIR="${SampShell_TRASHDIR:-$SampShell_gendir/.trash}"

## The temporary directory for SampShell.
# This is distinct from the normal `$TMPDIR`; that directory is sometimes wiped
# by the operating system, and I like having a folder full of scratch files that
# I can play around with if needed.
export SampShell_TMPDIR="${SampShell_TMPDIR:-$SampShell_gendir/.tmp}"

## The default folder for saving the shell's history.
# Note that unlike most other variables, this will not set a default if the
# variable is set, but to an empty value. This indicates that we don't want to
# store history at all.
export SampShell_HISTDIR="${SampShell_HISTDIR-$SampShell_gendir/.history}"

## Whether to enable xtrace (`set -x`) in scripts.
# (Tracing is enabled if `$SampShell_TRACE` is a non-empty value)
#
# When set, assuming all scripts are `.`ing this file, this should propagate
# through _all_ files that are called, which lets you debug more easily. It's
# important that this is exported, so scripts can see it.
#
# The `set -x` is actually done as the the end of this file.
export SampShell_TRACE="${SampShell_TRACE-}"

## Disable homebrew analytics.
# If set, homebrew (the mac package manager) won't send any analytics. We set it
# in `env.zsh` and not `interactive.sh` in case any config scripts decide to use
# homebrew themselves. (We _could_ check to see if homebrew is installed, but
# that significantly complicates things, and there's no harm in setting it.)
export HOMEBREW_NO_ANALYTICS=1

################################################################################
#                                  Functions                                   #
################################################################################

# Note that we `unalias` all these functions right before defining them, just
# on the off chance that they were `alias`ed.
unalias SampShell_unalias >/dev/null 2>&1
SampShell_unalias () {
   if [ "$#" = 0 ]; then
      echo 'usage: SampShell_unalias name [name ...]' >&2
      return 1
   fi

   while [ "$#" != 0 ]; do
      unalias "$1" >/dev/null 2>&1 || : # `:` to ensure we succeed always
      shift
   done
}

## Logs a message if `$SampShell_VERBOSE` is enabled; It forwards all its args
# to printf, except it adds a newline to the end of the format argument.
SampShell_unalias SampShell_log
SampShell_log () {
   [ -z "${SampShell_VERBOSE-}" ] && return 0
   : "${1:?a format is needed}"
   printf -- "$@" && echo # Make sure we print the trailing newline
}

## Same as `.`, except it only sources files if the first argument exists; will
# return `0` if the file doesn't exist.
SampShell_unalias SampShell_dot_if_exists
SampShell_dot_if_exists () {
   if [ -e "${1:?need file to source}" ]; then
      . "$@"
   else
      SampShell_log 'Not sourcing non-existent file: %s' "$1"
      return 0 # Ensure a noznero status in the error case
   fi
}

## Returns whether or not the given command exists.
SampShell_unalias SampShell_command_exists
SampShell_command_exists () {
   command -v "${1:?need command to check}" >/dev/null 2>&1
}

## Adds its argument to the start of '$PATH' if it doesnt already exist; same as
# PATH="$PATH:$1", except it handles the case when PATH does't exist, and makes
# sure to not add $1 if it already exists; note that this doesn't export PATH.
# Notably this doesn't export the path.
SampShell_unalias SampShell_add_to_path
SampShell_add_to_path () {
   case ":${PATH-}:" in
      *:"${1:?need a path to add to PATH}":*) : ;;
      *) PATH="$1${PATH:+:}$PATH" ;;
   esac
}

## Enable all debugging capabilities of SampShell, as well as the current shell
SampShell_unalias SampShell_debug
SampShell_debug () {
   export SampShell_VERBOSE=1 SampShell_TRACE=1 && set -o xtrace && set -o verbose
}

## Disable all debugging capabilities of SampShell, as well as the current shell
SampShell_unalias SampShell_undebug
SampShell_undebug () {
   unset -v SampShell_VERBOSE SampShell_TRACE && set +o xtrace && set +o verbose
}

## CD's to the directory containing a file
SampShell_unalias SampShell_cdd
SampShell_cdd () {
   if [ "$#" -eq 2 ] && [ "$1" = -- ]; then
      shift
   elif [ "$#" -ne 1 ] || [ "$1" = -h ] || [ "$1" = --help ] || [ "$1" = -- ]; then
      # Set exit status, and where to redirect
      if [ "$1" = -h ] || [ "$1" = --help ]; then
         set -- 0
      else
         set -- 2
      fi

      echo 'usage: cdd [-h/--help] [--] directory' >&"$((1 + $1))"
      return "$1"
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

################################################################################
#                                  Setup PATH                                  #
################################################################################

## Add POSIX-compliant bin scripts to the `$PATH`.
# They're only added if `$SampShell_ROOTDIR` is set. A warning is logged if the
# `$SampShell_ROOTDIR` is not a directory (ie doesn't exist or is a file), but
# the scripts are still added.
#
# Ensure also ensures that that `$SampShell_ROOTDIR/posix/bin` is only added
# once, so as to not pollute the `$PATH`
#
# Note that we allow `$SampShell_ROOTDIR` to be empty, in case the files are
# stored under `/posix/bin`.
if [ -n "${SampShell_ROOTDIR+1}" ]; then
   if ! [ -d "$SampShell_ROOTDIR/posix/bin" ]; then
      SampShell_log '[WARN] POSIX bin location (%s/posix/bin) does not exist; still adding it to $PATH though' "$SampShell_ROOTDIR"
   fi

   SampShell_add_to_path "$SampShell_ROOTDIR/posix/bin"
   export PATH
fi

################################################################################
#                           Respect SampShell_TRACE                            #
################################################################################

## Respect `SampShell_TRACE` in all scripts that `.` this file, regardless of
# whether they're a SampShell script or not. Note we want this as the last thing
# in this file, so that we don't print the traces for the other setup.
[ -n "${SampShell_TRACE-}" ] && set -o xtrace

## Ensure the return value from this script is `0`, regardless of `set -o`.
true 
