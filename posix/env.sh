#### POSIX-compliant SampShell definitions for scripts and interactive shells.
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

## Logs a message only if `$SampShell_VERBOSE` is enabled.
# If `$SampShell_VERBOSE` is nonempty, all arguments are forwarded to `printf`,
# and a newline is appended at the end.
SampShell_log () {
   [ -z "${SampShell_VERBOSE-}" ] && return 0
   printf -- "$@" && echo # Make sure we print the trailing newline
}

## The same as `.`, except it doesn't fail on missing files.
# This will log (via `SampShell_log`) a message if the file doesn't exist.
#
# This returns an error if the `.` itself failed, or if the file doesn't exist
# and `SampShell_log` failed for some reason.
SampShell_dot_if_exists () {
   if [ -e "${1:?need file to source}" ]; then
      . "$@"
   else
      SampShell_log 'SampShell_dot_if_exists: Ignoring non-extant file: %s' "$1"
   fi
}

## Returns whether or not the given command exists.
# This not only checks for functions, but also aliases, scripts via `$PATH`,
# keywords, and anything else that's valid as a command.
SampShell_command_exists () {
   command -v "${1:?need command to check}" >/dev/null 2>&1
}

## Prepends its argument to '$PATH', unless that argument is already in $PATH.
# This ensures that each PATH entry is only added once, as there's no real
# reason to have duplicates. This also handles the case where `$PATH` is empty.
#
# This notably does _not_ export `$PATH`; that's the caller's job.
SampShell_add_to_path () {
   case :${PATH-}: in
      *:"${1:?need a path to add to PATH}":*) : ;; # It's already there!
      *) PATH="$1${PATH:+:}$PATH" ;; # It's not present; prepend it.
   esac
}

## Enables debugging mode
# This enables all of SampShell_debug's debugging capabilities, as well as the
# current shell; it's expected that this is overwritten in per-shell config.
SampShell_debug () {
   export SampShell_VERBOSE=1 SampShell_TRACE=1 && set -o xtrace -o verbose
}

## Enables debugging mode
# This disables all of SampShell_debug's debugging capabilities, as well as the
# current shell; it's expected that this is overwritten in per-shell config.
SampShell_undebug () {
   unset -v SampShell_VERBOSE SampShell_TRACE && set +o xtrace +o verbose
}

################################################################################
#                                  Setup PATH                                  #
################################################################################

## Add POSIX-compliant scripts to the `$PATH` if `$SampShell_ROOTDIR` is set.
# (If `$SampShell_ROOTDIR` is unset, nothing happens.)
#
# This will export `PATH` if and only if `$SampShell_ROOTDIR` is set, so that we
# don't muck with it if `$SampShell_ROOTDIR` isn't set before `.`ing this file.
#
# A warning is logged (via `SampShell_log`) if `$SampShell_ROOTDIR/posix/bin`
# does not exist, or is not a directory. However, it's still added to the $PATH
# regardless of this.
#
# Note that we allow `$SampShell_ROOTDIR` to be empty, in case the files are
# stored under `/posix/bin` for some reason.
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

## Enables xtrace mode if `SampShell_TRACE` is set.
# This enables it in both scripts and interactive shells, as this allows us to
# trace third-party scripts as well, if need be.
[ -n "${SampShell_TRACE-}" ] && set -o xtrace

################################################################################
#                           Ensure Successful Return                           #
################################################################################

## Ensure that this script's return value is successful if we get here.
true 
