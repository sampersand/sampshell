clean_shell () {
   [ "$#" -eq 0 ] && set /bin/sh
   [ -n "${TERM+1}"  ] && set  "TERM=$TERM"  "$@"
   [ -n "${HOME+1}"  ] && set  "HOME=$HOME"  "$@"
   [ -n "${SHLVL+1}" ] && set "SHLVL=$SHLVL" "$@"
   env -i "$@"
}

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

   alias ..='cd ..'
   alias ...='cd ../..'
   alias ....='cd ../../..'
   alias .....='cd ../../../..'
fi

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
