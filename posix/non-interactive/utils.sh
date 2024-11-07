# Same as `.`, except only does it if the file exists.
SampShell_source_if_exists () {
	[ -e "${1:?}" ] && . "$@"
}

# Same as `.`, except warns if it doesn't exist.
SampShell_source_or_warn () {
	until [ "$#" = 0 ]; do
		if [ -e "$1" ]; then
			. "$1"
		else
			echo "[WARN] Unable to source file: $1" >&2
		fi
		shift
	done
}

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

## Parallelize a function by making a new job once per argument given
# Oh boy, it's far too annoying making this without `local`
if SampShell_command_exists local; then
	SampShell_parallelize_it () {
		local expand fn skipchr

		while :; do
			case "$1" in
				-h)
					cat <<-EOS
						usage: $0 [options] [--] fn [args ...]
						options:
						   -e      use expansion on 'args'
						   -X      don't have a skipchar; overrides -x
						   -x[CHR] set the skipchar; if omitted defaults to 'x'
						   -fFUNC  sets the function to execute; if given, omit 'fn'
						           after '--'.
						This command executes 'fn' once for each arg as background job
					EOS
					return 64 ;;
				-e) expand=1 ;;
				-X) skipchr= ;;
				-x) skipchr="${1#-x}"; skipchr="${skipchr:-x}" ;;
				-f*)
					fn="${1#-f}"
					if [ -z "$fn" ]; then fn="$2"; shift; fi ;;
				--) break ;;
				*) break ;;
			esac
			shift
		done

		if [ "$1" = "--" ]; then
			shift
		elif [ -z "$fn" ]; then
			fn="$1"
			shift
		fi

		if [ -z "$fn" ]; then
			echo "no function given!" >&2
			return 1
		elif ! type "$fn" >/dev/null 2>&1; then
			echo "function '$fn' is not executable" >&2
			return 2
		fi

		until [ "$#" = 0 ]; do
			if [ -n "$skipchr" ] && [ "$skipchr" = "$2" ]; then
				shift
			elif [ -n "$expand" ]; then
				"$fn" $1 &
			else
				"$fn" "$1" &
			fi
			shift
		done
	}

	command -V parallelize_it >/dev/null 2>&1 || alias parallelize_it=SampShell_parallelize_it
fi

