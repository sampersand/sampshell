# Change directories to the one that contains a file.
cdd () {
	cd "$(dirname "$1")"
}

alias cdtmp='cd "$SampShell_TMPDIR"'

# Aliases for going up directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
