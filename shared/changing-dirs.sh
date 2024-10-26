# Change directories to the one that contains a file.
cdd () {
	cd "$(dirname "$1")"
}

alias cdtmp='cd "${SampShell_TMPDIR?}"'

# Aliases for going up directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Make sure that CDPATH always starts with `:`, so we won't cd elsewhere on accident.
add_to_cd_path () {
	[ "$#" -eq 0 ] && set -- "$PWD"

	until [ "$#" -eq 0 ]; do
		SampShell_scratch="$(realpath "$arg")" || return
		CDPATH=":$SampShell_scratch$CDPATH"
	done

	unset -v SampShell_scratch
}
