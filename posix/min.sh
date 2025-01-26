export SampShell_EDITOR="${SampShell_EDITOR:-sublime4}"
: "${SampShell_gendir:=${SampShell_ROOTDIR:-${HOME:-/tmp}}}"
export SampShell_TRASHDIR="${SampShell_TRASHDIR:-$SampShell_gendir/.trash}"
export SampShell_TRACE="${SampShell_TRACE-}"
export HOMEBREW_NO_ANALYTICS=1

SampShell_add_to_path () {
   case :${PATH-}: in
   *:"${1:?need a path}":*) :                      ;; # It's already there!
   *)                       PATH=$1${PATH:+:}$PATH ;; # Not present; prepend it.
   esac
}

SampShell_does_command_exist () {
   command -v "${1:?need command to check}" >/dev/null 2>&1
}

if [ -n "${SampShell_TRACE-}" ]; then
   export SampShell_TRACE # Export it in case it's not already exported.
   set -o xtrace
fi

true
