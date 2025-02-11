#!zsh

# Set `SampShell_ROOTDIR` to the directory containing this file if it's not already set.
: "${SampShell_ROOTDIR:=${${(%):-%N}:P:h}}"

# Source the the POSIX-compliant profile, in sh-style emulation mode.
emulate sh -c '. "$SampShell_ROOTDIR/.sampshell_profile"'

## TODO: Do we want to set `fpath` here?
