# Change directories to the one that contains a file.
cdd () { cd "$(dirname "$1")"; }
cdtmp () { cd "${SampShell_TMPDIR?}"; }

# Aliases for going up directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Make sure that CDPATH always starts with `:`, so we won't cd elsewhere on accident.
add_to_cd_path () {
	[ "${#}" -eq 0 ] && set -- "${PWD}"

	SampShell_scratch=
	until [ "$#" -eq 0 ]; do
		SampShell_scratch="$(realpath "$1")" || return
		CDPATH=":${SampShell_scratch}${CDPATH}"
		shift
	done

	unset -v SampShell_scratch
}
