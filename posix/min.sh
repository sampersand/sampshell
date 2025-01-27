
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

alias t=trash
alias m=mv-safe

j () { jobs "$@"; }
if [ -n "$SampShell_EDITOR" ]; then
   alias s=subl
   alias ss=ssubl
   alias ssubl='subl --create'
   alias sbul=subl
   alias ssbul=ssubl
fi

alias cpu='top -o cpu'
alias purge='command rm -ridP' ## Purge deletes something entirely
