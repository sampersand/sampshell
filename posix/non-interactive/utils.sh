# Helper command used to see if all the commands given exist
SampShell_command_exists () {
	while [ "$#" -ne 0 ]; do
		command -V "$1" >/dev/null 2>&1 || return 1
		shift
	done

	return 0
}

# Cd's to a directory
SampShell_cdd () {
	if [ "$#" -eq 2 ] && [ "$1" = -- ]; then
		shift
	elif [ "$#" -ne 1 ] || [ "$1" = -h ] || [ "$1" == --help ]; then
		printf "usage: cdd [-h/--help] [--] directory" >&"$(echo "$(( 1 + (! "$#") ))" )"
		return "$((! "$#"))"
	fi

	SampShell_scratch="$(dirname -- "$1" && printf x)" || {
		set -- "$?"
		unset -v SampShell_scratch
		return "$1"
	}
	set -- "${SampShell_scratch%?x}"
	unset -v SampShell_scratch
	[ "$1" = - ] && set -- ./-
	CDPATH= cd -- "$1"
}
