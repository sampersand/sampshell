if [ -z "${SampShell_VERBOSE+1}" ]; then
   case "$-" in
   *i*) SampShell_VERBOSE=1 ;;
   *)   SampShell_VERBOSE=  ;;
   esac
fi
export SampShell_VERBOSE
export SampShell_EDITOR="${SampShell_EDITOR:-sublime4}"
: "${SampShell_gendir:=${SampShell_ROOTDIR:-${HOME:-/tmp}}}"
export SampShell_TRASHDIR="${SampShell_TRASHDIR:-$SampShell_gendir/.trash}"
export SampShell_TMPDIR="${SampShell_TMPDIR:-$SampShell_gendir/.tmp}"
export SampShell_HISTDIR="${SampShell_HISTDIR-$SampShell_gendir/.history}"
export SampShell_TRACE="${SampShell_TRACE-}"
export HOMEBREW_NO_ANALYTICS=1
unalias SampShell_unalias >/dev/null 2>&1 # Unalias this one in case it existed.
SampShell_unalias () {
   if [ "$#" = 0 ]; then
      echo >&2 'usage: SampShell_unalias name [name ...]'
      return 1
   fi

   unalias "$@" >/dev/null 2>&1 || : # To ensure we always succeed
}
SampShell_unalias SampShell_log SampShell_dot_if_exists SampShell_add_to_path
SampShell_unalias SampShell_does_command_exist SampShell_debug SampShell_undebug
SampShell_log () {
   [ -z "${SampShell_VERBOSE-}" ] && return 0
   printf -- "$@" && echo # Make sure we print the trailing newline
}
SampShell_dot_if_exists () {
   if [ -e "${1:?need file to source}" ]; then
      . "$@"
   else
      SampShell_log 'SampShell_dot_if_exists: Ignoring non-extant file: %s' "$1"
   fi
}
SampShell_add_to_path () {
   case :${PATH-}: in
   *:"${1:?need a path}":*) :                      ;; # It's already there!
   *)                       PATH=$1${PATH:+:}$PATH ;; # Not present; prepend it.
   esac
}
SampShell_does_command_exist () {
   command -v "${1:?need command to check}" >/dev/null 2>&1
}
SampShell_debug () {
   export SampShell_VERBOSE=1 SampShell_TRACE=1 && set -o xtrace -o verbose
}
SampShell_undebug () {
   unset -v SampShell_VERBOSE SampShell_TRACE && set +o xtrace +o verbose
}
if [ -n "${SampShell_ROOTDIR+1}" ]; then
   if ! [ -d "$SampShell_ROOTDIR/posix/bin" ]; then
      SampShell_log '[WARN] POSIX bin location (%s/posix/bin) does not exist; still adding it to $PATH though' "$SampShell_ROOTDIR"
   fi

   SampShell_add_to_path "$SampShell_ROOTDIR/posix/bin"
   export PATH
fi
if [ -n "${SampShell_TRACE-}" ]; then
   export SampShell_TRACE # Export it in case it's not already exported.
   set -o xtrace
fi
true
