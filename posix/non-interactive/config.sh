#!/bin/sh

# Default variables that should always be available
export SampShell_EDITOR="${SampShell_EDITOR:-sublime4}"

export SampShell_GENERATED_DIR="${SampShell_GENERATED_DIR:-"$HOME/.sampshell-files"}" # Where generated files should go

if [ "$SampShell_GENERATED_DIR" -ef "$HOME" ]; then
	echo '[WARN] $SampShell_GENERATED_DIR is set to $HOME! This may cause some naming conflicts!'
fi

export SampShell_TRASHDIR="${SampShell_TRASHDIR:-"$SampShell_GENERATED_DIR/.trash"}"
export SampShell_TMPDIR="${SampShell_TMPDIR:-"$SampShell_GENERATED_DIR/.tmp"}"
export SampShell_HISTDIR="${SampShell_HISTDIR-"$SampShell_GENERATED_DIR/.history"}" # Allow it to be empty.
