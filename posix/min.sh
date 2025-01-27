
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
set +o nounset

HISTSIZE=500 # How many history entries for the editor to keep.
if [ -z "${HISTFILE+1}" ]; then
   if [ -n "${SampShell_HISTDIR+1}" ] && [ -z "$SampShell_HISTDIR" ]; then
      echo '[INFO] Not setting HISTFILE; SampShell_HISTDIR is set to the empty string'
   else
      HISTFILE=${SampShell_HISTDIR-$HOME}/.sampshell_history
   fi
elif [[ -z ${HISTFILE} ]]; then
   echo '[INFO] Not defaulting HISTFILE; it is set to the empty string'
fi
SampShell_does_command_exist history || eval 'history () { fc -l "$@"; }'
SampShell_unalias h
h () {
   [ "$#" = 0 ] && [ ! -t 1 ] && set -- 0
   history "$@"
}
if [ -z "$SampShell_no_experimental" ]; then
   ping () { curl --connect-timeout 10 "${1:-http://www.example.com}"; }

   alias k+='kill %+'
   alias touchd='mkdir -p' # alias incase i ever end up using it

   ttouch () for file; do  # Same as `touch`, except it will create directories as needed.
      mkdir -p $file:h && touch $file
   done
   mkdircd () { mkdir -p $@ && cd $@; }
   alias cdmkdir=mkdircd
   alias cdm=mkdircd

   mkd () { mkdir -p $@; }
   mkf () { mkdir -p ${@:h} && command touch $@; }
   symlink () {
      ln -s ${1?need existing file name} ${2?need name of destination}
   }
fi
set -o noclobber
alias t=trash
alias m=mv-safe
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias rmm='rm -f'
alias mvv='mv -f'
alias cpp='cp -f'
alias ls='ls -AFq' # Print out `.` files, longform, metric sizes, and colours.
alias ll='ls -l'   # Shorthand for `ls -al`
alias parallelize_it=SampShell_parallelize_it
alias cdd=SampShell_cdd
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
j () { jobs "$@"; }
if [ -n "$SampShell_EDITOR" ]; then
   alias s=subl
   alias ss=ssubl
   alias ssubl='subl --create'
   alias sbul=subl
   alias ssbul=ssubl
fi
SampShell_unalias cdtmp
cdtmp () {
   : "${SampShell_TMPDIR:=$HOME/tmp}"
   if ! [ -e "${SampShell_TMPDIR:?}" ]; then
      mkdir -p -- "$SampShell_TMPDIR" || return
   fi

   CPATH= cd -- "$SampShell_TMPDIR/$1"
}
SampShell_unalias cdss
cdss () {
   CDPATH= cd -- "${SampShell_ROOTDIR?}/$1";
}
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
SampShell_unalias SampShell_cdd
SampShell_cdd () {
   if [ "$#" -eq 2 ] && [ "$1" = -- ]; then
      shift
   elif [ "$#" -ne 1 ] || [ "$1" = -h ] || [ "$1" = --help ] || [ "$1" = -- ]; then
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
SampShell_unalias reload
reload () { SampShell_reload "$@"; }
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
   if [ "$#" -ne 0 ]; then
      set -- "$SampShell_ROOTDIR/$1"
      printf 'Reloading SampShell file: %s\n' "$1"
      . "$1"
      return
   fi

   set -- "$SampShell_ROOTDIR/both"
   if  [ -n "$ENV" ]; then
      if [ "$1" -ef "$ENV" ]; then
         echo 'Not loading $ENV; same as SampShell'
      else
         printf 'Reloading $ENV: %s\n' "$ENV"
         . "$ENV" || return
      fi
   fi
   printf 'Reloading SampShell: %s\n' "$1"
   . "$1"
}
SampShell_unalias SampShell_parallelize_it
SampShell_parallelize_it () {
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
   if ! command -v "$1" >/dev/null 2>&1; then
      echo 'SampShell_parallelize_it: no function given' >&2
      unset -v SampShell_parallelize_it
      return 1
   fi
   if ! command -v "$1" >/dev/null 2>&1; then
      printf 'SampShell_parallelize_it: fn is not executable: %s\n' "$1" >&2
      return 1
   fi


   while [ "$#" -gt 1 ]; do
      if [ -n "${SampShell_scratch-}" ]; then
         unset -v SampShell_scratch
         "$1" $2 &
         SampShell_scratch=$1
         shift 2
         set -- "$SampShell_scratch" "$@"
         SampShell_scratch=1
      else
         "$1" "$2" &
         SampShell_scratch=$1
         shift 2
         set -- "$SampShell_scratch" "$@"
         unset -v SampShell_scratch
      fi
   done

   unset -v SampShell_scratch
}
