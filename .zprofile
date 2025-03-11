# If SampShell_DISABLED is set to a non-empty value, then don't do any setup
[[ -n $SampShell_DISABLED ]] && return

# Set `SampShell_ROOTDIR` to the directory containing this file if it's not already set.
# (Note this `${}` uses prompt substitution to find the path to folder containing this directory;
# we can't use `$0` because it can be changed around by a lot of scripts.)
: "${SampShell_ROOTDIR:=${${(%):-%N}:P:h}}"

# Source the the POSIX-compliant profile, in sh-style emulation mode.
emulate sh -c '. "$SampShell_ROOTDIR/.profile"'
