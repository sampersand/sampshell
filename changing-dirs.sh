## Cd aliases

# Change directories to the one that contains a file.
cdd () {
	cd "$(dirname "$1")"
}

# Aliases for going up directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# ZSH-specific options
[ -n "$ZSH_VERSION" ] && . "$SampShell_HOME/zsh/changing-dirs.zsh"
