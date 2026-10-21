#!/bin/sh

## Configuration universal to the login shell.
# Login shells are the first shell that are run when someone logs in; Usually,
# login shells setup configuration (eg env variables, config files, etc.) that
# that all child processes inherit.
#
# This file only sets up and exports environment variables that should always be
# present, such as SampShell variables expected by `bin/` programs, a few POSIX
# variables, and a handful of misc ones (eg `HOMEBREW_NO_ANALYTICS`). It is
# totally POSIX-compliant, as it's meant to be loaded by any login shell.
#
# Login files shouldn't set up anything that's shell-specific, such as prompts
# or history expansions, as they're only run on "login"---see `.shrc` for code
# that's expected to be run by every interactive shell. However, this program is
# intentionally idempotent, so that it can be loaded from interactive shells too
# without causing issues.
#
# Since the purpose of this is to setup common config across _all_ shells, there
# is intentionally minimal shell-specific setup here (though sometimes it cannot
# be avoided).
##

## If SampShell_DISABLED is set to a non-empty value, then don't do any setup.
[ -n "${SampShell_DISABLED-}" ] && return

################################################################################
#                                                                              #
#                  Ensure $SampShell_ROOTDIR is set and valid                  #
#                                                                              #
################################################################################

## Makes sure that `$SampShell_ROOTDIR` is set, which is used frequently within
# config files. If it's not set, it defaults to `~/sampshell`, and warns.
if [ -z "${SampShell_ROOTDIR-}" ]; then
   # Guess a default home directory (hope it works) and warn.
   SampShell_ROOTDIR=$HOME/sampshell
   printf >&2 '[WARN] Defaulting $SampShell_ROOTDIR to %s\n' "$SampShell_ROOTDIR"
fi

## Warn if `SampShell_ROOTDIR` isn't a directory
if [ ! -d "$SampShell_ROOTDIR" ]; then
   printf >&2 '[WARN] $SampShell_ROOTDIR does not exist/isnt a dir: %s\n' "$SampShell_ROOTDIR"
fi

# Ensure `SampShell_ROOTDIR` is exported if it wasn't already.
export SampShell_ROOTDIR

################################################################################
#                                                                              #
#                    Other SampShell Environment Variables                     #
#                                                                              #
################################################################################

if [ -z "${SampShell_STATE_HOME-}" ]; then
   SampShell_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}/sampshell
fi

if [ -z "${SampShell_CACHE_HOME-}" ]; then
   SampShell_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}/sampshell
fi

mkdir -p "$SampShell_STATE_HOME" "$SampShell_CACHE_HOME" || : # TODO: error?
export SampShell_STATE_HOME SampShell_CACHE_HOME

## These variables are used in various SampShell utilities, and are expected to
# always be present. It follows XDG Base Directory specifications, and stores
# all files in the relevant folders.

[ -z "${SampShell_HISTDIR-}"  ] && SampShell_HISTDIR=${SampShell_STATE_HOME:?}/history
export SampShell_HISTDIR

mkdir -p "$SampShell_HISTDIR" || echo "oops failed: $?" # TODO, removeme?

## Misc variables
export SampShell_EDITOR="${SampShell_EDITOR:-subl}"
export SampShell_EXPERIMENTAL="${SampShell_EXPERIMENTAL-1}"

################################################################################
#                                                                              #
#                          Misc Environment Variables                          #
#                                                                              #
################################################################################

# Words is something I use occasionally. Only set it if the variable isn't
# already set, and the file exists
if [ -z "${words-}" ]; then
   export words=/usr/share/dict/words
   [ -f "$words" ] || unset -v words
fi

## Disable homebrew analytics.
# If set, homebrew (the mac package manager) won't send any analytics. We set it
# in `.profile` and not `.shrc` in case any config scripts decide to
# use homebrew themselves. (We _could_ check to see if homebrew is installed,
# but that significantly complicates things, and there's no harm in setting it.)
if [ "$(uname)" = Darwin ]; then
   export HOMEBREW_NO_ANALYTICS=1
fi

## Set `LANG` if it's not already present. (This is a POSIX env variable that I
# don't see much of a need for, but eh whatever, why not add it in.)
export LANG="${LANG-en_US.UTF-8}"

# Add `$SampShell_ROOTDIR/ruby/include` to the list of imports for `RUBYLIB` if
# it's not already there
case ":${RUBYLIB-}:" in
   *:"$SampShell_ROOTDIR/ruby/include:"*) : ;; # already there
   *) RUBYLIB=$SampShell_ROOTDIR/ruby/include${RUBYLIB:+:}$RUBYLIB ;; # added
esac
export RUBYLIB # export it

export IRBRC="$SampShell_ROOTDIR/.irbrc" # Set ruby rc dir

################################################################################
#                                                                              #
#                                  Export ENV                                  #
#                                                                              #
################################################################################

## Set `ENV`, the POSIX-compliant environment variable that should be `.`d when
# in in interactive. Note that we intentionally use single quotes, as POSIX
# specifies that the variable is subject to parameter expansion, and if we used
# double quotes, `$SampShell_ROOTDIR`'s expansion might contain _another_ path.
if [ -z "${ENV+1}" ]; then
   export ENV='${SampShell_ROOTDIR:-$HOME}/.shrc'
fi

################################################################################
#                                                                              #
#                     Prepend SampShell's bin to the $PATH                     #
#                                                                              #
################################################################################

## Prepend things to `PATH` unless they're already there.
SampShell_add_PATH () {
   # If the directory doesn't exist, then just return early early.
   [ -d "$1" ] || return

   # Only add it if it's not there
   case :${PATH-}: in
   *:"$1":*) :                      ;; # It's already there!
   *)        PATH=$1${PATH:+:}$PATH ;; # Not present; prepend it.
   esac
}

## Home directory bins
SampShell_add_PATH "$HOME/bin"
SampShell_add_PATH "$HOME/.local/bin"

## Universal scripts I always want available
SampShell_add_PATH "$SampShell_ROOTDIR/bin/posix"
SampShell_add_PATH "$SampShell_ROOTDIR/bin/universal"
SampShell_add_PATH "$SampShell_ROOTDIR/bin/git"

## MacOS-specific scripts
[ "$(uname)" = Darwin ] && SampShell_add_PATH "$SampShell_ROOTDIR/bin/macOS"

## Add in "experimental" scripts I'm working on and haven't quite completed.
[ -n "${SampShell_EXPERIMENTAL-}" ] && SampShell_add_PATH "$SampShell_ROOTDIR/bin/experimental"

## Make sure `SampShell_add_PATH` doesn't escape this startup file.
unset -f SampShell_add_PATH

## Ensure `PATH` is exported so programs can get SampShell executables.
export PATH
