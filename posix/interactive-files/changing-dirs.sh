## Changes to the SampShell tmp directory, creating it unless it exists already.
cdtmp () {
	if ! [ -e "${SampShell_TMPDIR:?}" ]; then
		mkdir -p -- "$SampShell_TMPDIR" || return
	fi

	CPATH= cd -- "$SampShell_TMPDIR/${1-}"
}

## CD to sampshell; if an arg is given it's the suffix to also go to
cdss () {
	CDPATH= cd -- "${SampShell_ROOTDIR:?}/${1-}";
}

# Make sure that CDPATH always starts with `:`, so we won't cd elsewhere on accident.
add_to_cd_path () {
	if [ "$#" -eq 0 ]; then
		echo 'usage: add_to_cd_path path [more ...]' >&2
		return 64
	fi

	SampShell_scratch=
	while [ "$#" -ne 0 ]; do
		SampShell_scratch=$(realpath -- "$1" && printf x) || {
			printf 'add_to_cd_path: unable to get realpath of %s' \
				"$1" >&2
			return 1
		}
		CDPATH=":${SampShell_scratch%?x}${CDPATH}"
		shift
	done

	unset -v SampShell_scratch
	return 0
}
