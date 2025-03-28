###
# Basic SampShell definitions for _all_ interactive POSIX-complaint shells.
#
# This file must be strictly POSIX-compliant, as it will be loaded for POSIX-
# compliant shells. However, unlike `env.sh`, we don't expect this file to be
# `.`d in the middle of scripts with arbitrary settings. As such, we can relax
# the restrictions somewhat (eg, we don't need to do `${var-}` in case the
# `set -u` is enabled).
#
# It's expected that this file will be `.`d after `env.sh` is; as such, all of
# the definitions within `env.sh` are expected to be visible here.
###

SampShell_does_command_exist () {
   command -v "${1:?need command to check}" >/dev/null 2>&1
}
SampShell_unalias () {
   if [ "$#" = 0 ]; then
      echo >&2 'usage: SampShell_unalias name [name ...]'
      return 1
   fi

   unalias "$@" >/dev/null 2>&1 || : # To ensure we always succeed
}



## Ensure `nounset` is its default, so `$doesnt_exist` is an empty string.
set +o nounset

################################################################################
#                                   History                                    #
################################################################################

HISTSIZE=500 # How many history entries for the editor to keep.

# Only default `HISTFILE` if it's unset; if it's set to an empty value, it
# indicates we don't want to store history.
if [ -z "${HISTFILE+1}" ]; then
   if [ -n "${SampShell_HISTDIR+1}" ] && [ -z "$SampShell_HISTDIR" ]; then
      echo '[INFO] Not setting HISTFILE; SampShell_HISTDIR is set to the empty string'
   else
      HISTFILE=${SampShell_HISTDIR-$HOME}/.sampshell_history
      # TODO: do we want to export histfie for subshells
   fi
elif [[ -z ${HISTFILE} ]]; then
   echo '[INFO] Not defaulting HISTFILE; it is set to the empty string'
fi

## Ensure we have the `history` command if it doesnt exist already.
SampShell_does_command_exist history || eval 'history () { fc -l "$@"; }'

## Add in the `h` command, which is like `history`, except it does `history 0`
# when not connected to a tty (eg when we're piping it into grep).
SampShell_unalias h
h () {
   # If no arguments are given, and we're not outputting to a tty, then
   # default to printing all commands.
   [ "$#" = 0 ] && [ ! -t 1 ] && set -- 0
   history "$@"
}

################################################################################
#                                 Experimental                                 #
################################################################################

# Load experimental changes, unless they're disabled.
if [ -z "$SampShell_no_experimental" ]; then
   ping () { curl --connect-timeout 10 "${1:-http://www.example.com}"; }

   alias k+='kill %+'

   ## Creating files
   alias touchd='mkdir -p' # alias incase i ever end up using it

   ttouch () for file; do  # Same as `touch`, except it will create directories as needed.
      mkdir -p $file:h && touch $file
   done

   ## Creating Folders (& cding to them)
   mkdircd () { mkdir -p $@ && cd $@; }
   alias cdmkdir=mkdircd
   alias cdm=mkdircd

   mkd () { mkdir -p $@; }
   mkf () { mkdir -p ${@:h} && command touch $@; }

   ## Symlinks
   symlink () {
      ln -s ${1?need existing file name} ${2?need name of destination}
   }
fi

################################################################################
#                                    Safety                                    #
################################################################################

# Don't clobber files with `>`; must use `>|`
set -o noclobber

## Shorthand aliases for the "safer" options
alias t=trash
alias m=mv-safe

# Override builtins with safer versions.
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# Still let you do the builtins
alias rmm='rm -f'
alias mvv='mv -f'
alias cpp='cp -f'

################################################################################
#                                   Aliases                                    #
################################################################################

## Listing files
alias ls='ls -AFq' # Print out `.` files, longform, metric sizes, and colours.
alias ll='ls -l'   # Shorthand for `ls -al`

## Renaming sampshell methods
alias parallelize_it=SampShell_parallelize_it
alias cdd=SampShell_cdd
# alias debug=SampShell_debug
# alias undebug=SampShell_undebug

## Aliases for going up directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

## Shorthands
j () { jobs "$@"; }

# Setup the editor if it exists
if [ -n "$SampShell_EDITOR" ]; then
   alias s=subl
   alias ss=ssubl
   alias ssubl='subl --create'

   ## Spellchecks
   alias sbul=subl
   alias ssbul=ssubl
fi


################################################################################
#                             Changing Directories                             #
################################################################################

## Changes to the SampShell tmp directory, creating it unless it exists already.
SampShell_unalias cdtmp
cdtmp () {
   : "${SampShell_TMPDIR:=$HOME/tmp}"
   if ! [ -e "${SampShell_TMPDIR:?}" ]; then
      mkdir -p -- "$SampShell_TMPDIR" || return
   fi

   CPATH= cd -- "$SampShell_TMPDIR/$1"
}

## CD to sampshell; if an arg is given it's the suffix to also go to
SampShell_unalias cdss
cdss () {
   CDPATH= cd -- "${SampShell_ROOTDIR?}/$1";
}

## Adds the arguments to the `CDPATH`. This function makes sure that `CDPATH`
# always starts with a `:`, so we won't accidentally cd elsewhere on accident.
SampShell_unalias SampShell_add_to_cd_path
SampShell_add_to_cd_path () {
   if [ "$#" -eq 0 ]; then
      echo 'usage: SampShell_add_to_cd_path path [more ...]' >&2
      return 64
   fi

   SampShell_scratch=
   while [ "$#" -ne 0 ]; do
      SampShell_scratch=$(realpath -- "$1" && printf x) || {
         printf 'SampShell_add_to_cd_path: unable to get realpath of %s' "$1" >&2
         return 1
      }
      CDPATH=":${SampShell_scratch%?x}${CDPATH}"
      shift
   done

   unset -v SampShell_scratch
   return 0
}

################################################################################
#                                 Command Line                                 #
################################################################################

# Clear the screen; also uses the `clear` command if it exists
SampShell_unalias cls
cls () {
   SampShell_does_command_exist clear && { clear || return; }
   printf '\ec\e[3J'
}

# vvv Not needed, as no shells actually support `!` natively really.
# PS1='[!!! | ?$?] ${PWD##"${HOME:+"$HOME"/}"} ${0##*/}$ '

################################################################################
#                               Helper Functions                               #
################################################################################

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
         set -- 1
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
#                                    Utils                                     #
################################################################################
# Prints out how many arguments were passed; used in testing expansion syntax.
SampShell_unalias nargs
nargs () { echo "$#"; }

alias cpu='top -o cpu'

alias SampShell_copy=pbcopy # TODO: pbcopy on other systems
SampShell_unalias pbc
pbc () if [ "$#" = 0 ]; then
   SampShell_copy
else
   echo "$*" | SampShell_copy
fi

SampShell_does_command_exist pbpaste && alias pbp=pbpaste

## Deleting files
# `rm -d` is in safety.
alias purge='command rm -ridP' ## Purge deletes something entirely
SampShell_unalias ppurge
ppurge () { echo "todo: parallelize purging"; }

alias prargs=p
alias pargs=p

SampShell_unalias p
p () {
   SampShell_scratch=0

   while [ "$#" != 0 ]; do
      SampShell_scratch=$((SampShell_scratch + 1))
      printf '%3d: %s\n' "$SampShell_scratch" "$1"
      shift
   done

   unset -v SampShell_scratch
}

export SampShell_WORDS="${SampShell_WORDS:-/usr/share/dict/words}"
[ -z "$words" ] && export words="$SampShell_WORDS" # Only set `words` if it doesnt exist

SampShell_unalias clean_shell
clean_shell () {
   [ "$#" -eq 0 ] && set -- /bin/sh
   [ -n "${TERM+1}"  ] && set -- "TERM=$TERM"   "$@"
   [ -n "${HOME+1}"  ] && set -- "HOME=$HOME"   "$@"
   [ -n "${SHLVL+1}" ] && set -- "SHLVL=$SHLVL" "$@"
   env -i "$@"
}

## Reloads all configuration files
# This is the same as `SampShell_reload` so that it's easy to replace, as
# opposed to an alias.
SampShell_unalias reload
reload () { SampShell_reload "$@"; }

## Reloads SampShell.
# If given an argument, it `.`s `$SampShell_ROOTDIR/<arg>` and returns. If
# given no arguments, it first `.`s `$ENV` if it exists, and then will `.` all
# of SampShell (via `$SampShell_ROOTDIR/both`).
SampShell_unalias SampShell_reload
SampShell_reload () {
   if [ "$1" = -- ]; then
      shift
   elif [ "$1" = -h ] || [ "$1" = --help ]; then
      cat <<-'EOS'
      usage: SampShell_reload [--] path
             SampShell_reload [-h/--help]

      In the first form, sources '$SampShell_ROOTDIR/<path>' and returns.
      In the second, sources '$ENV' if it exists, then '$SampShell_ROOTDIR/both'
EOS
      return 64
   fi

   : "${SampShell_ROOTDIR?SampShell_ROOTDIR must be supplied}"

   # If we're given an argument, then that's the only thing to reload; do that,
   # and return.
   if [ "$#" -ne 0 ]; then
      set -- "$SampShell_ROOTDIR/$1"
      printf 'Reloading SampShell file: %s\n' "$1"
      . "$1"
      return
   fi

   set -- "$SampShell_ROOTDIR/both"

   # We've been given no arguments. First off, reload `$ENV` if it's present.
   if  [ -n "$ENV" ]; then
      # On the off chance that `$ENV` is `$SampShell_ROOTDIR/both`, don't reload
      # SampShell twice.
      if [ "$1" -ef "$ENV" ]; then
         echo 'Not loading $ENV; same as SampShell'
      else
         printf 'Reloading $ENV: %s\n' "$ENV"
         . "$ENV" || return
      fi
   fi

   # Now reload all of sampshell
   printf 'Reloading SampShell: %s\n' "$1"
   . "$1"
}

## Parallelize a function by making a new job once per argument given
SampShell_unalias SampShell_parallelize_it
SampShell_parallelize_it () {
   # Support for when the shell is ZSH, when we explicitly have `-e`.
   [ -n "$ZSH_VERSION" ] && setopt LOCAL_OPTIONS GLOB_SUBST SH_WORD_SPLIT

   if [ "${1-}" = -- ]; then
      shift
   elif [ "${1-}" = -e ]; then
      SampShell_scratch=1
      shift
   elif [ "$#" = 0 ] || [ "$1" = -h ] || [ "$1" = --help ]; then
      if [ "$1" = -h ] || [ "$1" = --help ]; then
         set -- 0
      else
         set -- 64
      fi
      {
         echo "usage: SampShell_parallelize_it [-e] [--] fn [args ...]"
         echo "(-e does shell expansion on args; without it, args are quoted)"
      } >&"$((1 + (! $1) ))"
      return "$1"
   fi

   # Make sure a function was given
   if ! command -v "$1" >/dev/null 2>&1; then
      echo 'SampShell_parallelize_it: no function given' >&2
      unset -v SampShell_parallelize_it
      return 1
   fi

   # Make sure the function is executable
   if ! command -v "$1" >/dev/null 2>&1; then
      printf 'SampShell_parallelize_it: fn is not executable: %s\n' "$1" >&2
      return 1
   fi


   while [ "$#" -gt 1 ]; do
      # If we're expanding...
      if [ -n "${SampShell_scratch-}" ]; then
         # Unset `SampShell_scratch` so the child process doesn't see it
         unset -v SampShell_scratch

         # Run the function
         "$1" $2 &

         # Remove argument #2
         SampShell_scratch=$1
         shift 2
         set -- "$SampShell_scratch" "$@"

         # Set it so we'll go into this block next time.
         SampShell_scratch=1
      else
         # Run the function
         "$1" "$2" &

         # Remove argument #2
         SampShell_scratch=$1
         shift 2
         set -- "$SampShell_scratch" "$@"

         # unset it so won't run the expand block.
         unset -v SampShell_scratch
      fi
   done

   unset -v SampShell_scratch
}
