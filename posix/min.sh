export SampShell_EDITOR="${SampShell_EDITOR:-sublime4}"
: "${SampShell_gendir:=${SampShell_ROOTDIR:-${HOME:-/tmp}}}"
export SampShell_TRASHDIR="${SampShell_TRASHDIR:-$SampShell_gendir/.trash}"
export SampShell_TRACE="${SampShell_TRACE-}"
export HOMEBREW_NO_ANALYTICS=1

if [ -n "${SampShell_TRACE-}" ]; then
   export SampShell_TRACE # Export it in case it's not already exported.
   set -o xtrace
fi

true
