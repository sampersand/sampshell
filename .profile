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
# or history expansions, as they're only run on "login"---see `.shrc`
# for code that's expected to be run by every interactive shell. However, this
# program is intentionally idempotent, so that it can be loaded from interactive
# shells too without causing issues.
#
# Since the purpose of this is to setup common config across _all_ shells, there
# are not shell-specific 
##

################################################################################
#                                                                              #
#                  Ensure $SampShell_ROOTDIR is set and valid                  #
#                                                                              #
################################################################################

## Find and export `SampShell_ROOTDIR`, the directory containing this file,
# which is used in numerous SampShell commands. If it's not set, the default
# location is ascertained in a handful of shells (see the code below), with a
# fallback of `~/.sampshell/shell`. If the file doesn't exist, it's warned.
if [ -n "${SampShell_ROOTDIR-}" ]; then
   # Already setup, nothing to do.
   :
elif [ -n "${ZSH_VERSION-}" ]; then
   # ZSH: Use the builtin `${${(%):-%N}:P:h}`. (This abuses the fact prompt-
   # expansion (via `${(%):-}`) to get the current file's path; We could also
   # use `${0:P:h}` instead, but that might get tripped up with the different
   # options zsh has to set `$0`, and this one's guarantee dto work.) We also
   # use `eval` because this syntax isn't valid POSIX syntax.
   eval 'SampShell_ROOTDIR=${${(%):-%N}:P:h}'
elif [ -n "${BASH_SOURCE-}" ]; then
   # BASH: Use `BASH_SOURCE` and the `&& printf x` trick to get the dir (as
   # there's no nicer way to do it.) Even though the syntax is valid posix, we
   # `eval` it so it's not parsed & compiled by shells if not needed.
   eval '
   SampShell_ROOTDIR=$(dirname -- "$BASH_SOURCE" && printf x) || return
   SampShell_ROOTDIR=$(realpath -- "${SampShell_ROOTDIR%?x}" && printf x) || return
   SampShell_ROOTDIR=${SampShell_ROOTDIR%?x}'
else
   # Guess a default home directory (hope it works) and warn.
   SampShell_ROOTDIR=$HOME/.sampshell/shell
   printf >&2 '[WARN] Defaulting $SampShell_ROOTDIR to %s\n' "$SampShell_ROOTDIR"
fi

## Warn if `SampShell_ROOTDIR` isn't a directory, and we're in interactive mode.
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

## These variables are used in various SampShell utilities, and are expected to
# always be present. The `SampShell_gendir` variable in particular is special,
# as it's not exported, and is used exclusively for defaults for the other
# exported values.

: "${SampShell_gendir:=${SampShell_ROOTDIR:-${HOME:-/tmp}}}"
export SampShell_EDITOR="${SampShell_EDITOR:-sublime4}"
export SampShell_TRASHDIR="${SampShell_TRASHDIR:-$SampShell_gendir/.trash}"
export SampShell_HISTDIR="${SampShell_HISTDIR-$SampShell_gendir/.history}"
export SampShell_WORDS="${SampShell_WORDS:-/usr/share/dict/words}"
export SampShell_CACHEDIR="${SampShell_CACHEDIR:-$SampShell_gendir/.cache}"
export SampShell_EXPERIMENTAL="${SampShell_EXPERIMENTAL-1}"

## TODO: Remove `SampShell_no_experimental`.
export SampShell_no_experimental=$(( ! SampShell_EXPERIMENTAL ))

################################################################################
#                                                                              #
#                          Misc Environment Variables                          #
#                                                                              #
################################################################################

## Words is something I use quite frequently; only assign `$words` though if it
# doesn't exist, and `$SampShell_WORDS` is a file.
if [ -z "${words-}" ] && [ -f "${SampShell_WORDS-}" ]; then
   export words="$SampShell_WORDS"
fi

## Disable homebrew analytics.
# If set, homebrew (the mac package manager) won't send any analytics. We set it
# in `.profile` and not `.shrc` in case any config scripts decide to
# use homebrew themselves. (We _could_ check to see if homebrew is installed,
# but that significantly complicates things, and there's no harm in setting it.)
if [ "$(uname)" = Darwin ]; then
   export HOMEBREW_NO_ANALYTICS=1
fi

## Use `vim` for editing history commands. (This is only really needed for
# shells without better history mechanisms, which are quite rare---even dash has
# history if `set -o emacs` is enabled.)
export FCEDIT=vim

## Set `LANG` if it's not already present. (This is a POSIX env variable that I
# don't see much of a need for, but eh whatever, why not add it in.)
export LANG="${LANG-en_US}"

# Add `$SampShell_ROOTDIR/ruby/include` to the list of imports for `RUBYLIB` if
# it's not already there
case ":${RUBYLIB-}:" in
   *:"$SampShell_ROOTDIR/ruby/include:"*) : ;; # already there
   *) RUBYLIB=$SampShell_ROOTDIR/ruby/include${RUBYLIB:+:}$RUBYLIB ;; # added
esac
export RUBYLIB # export it


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
   [ -e "$1" ] || return

   # Only add it if it's not there
   case :${PATH-}: in
   *:"$1":*) :                      ;; # It's already there!
   *)        PATH=$1${PATH:+:}$PATH ;; # Not present; prepend it.
   esac
}

## Home directory bins
SampShell_add_PATH "$HOME/bin"

## Universal scripts I always want available
SampShell_add_PATH "$SampShell_ROOTDIR/bin/universal"
SampShell_add_PATH "$SampShell_ROOTDIR/bin/git"

## MacOS-specific scripts
[ "$(uname)" = Darwin ] && SampShell_add_PATH "$SampShell_ROOTDIR/bin/macOS"

## Add in "experimental" scripts I'm working on and haven't quite completed.
[ -n "${SampShell_EXPERIMENTAL-}" ] && SampShell_add_PATH "$SampShell_ROOTDIR/bin/experimental"

# Make sure `SampShell_add_PATH`"$SampShell_ROOTDIR/bin/ doesn't escape this startup file."
unset -f SampShell_add_PATH

## Ensure `PATH` is exported so programs can get sampshell executables.
export PATH
