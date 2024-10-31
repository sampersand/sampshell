#!/bin/sh

# Default variables that should always be available
export SampShell_EDITOR="${SampShell_EDITOR:-sublime4}"
export SampShell_TRASHDIR="${SampShell_TRASHDIR:-"$HOME/.Trash/.sampshell-trash"}"
export SampShell_TMPDIR="${SampShell_TMPDIR:-"$HOME/tmp"}"
export SampShell_HISTDIR="${SampShell_HISTDIR-"$SampShell_ROOTDIR"/.sampshell-history}" # Allow it to be empty.
