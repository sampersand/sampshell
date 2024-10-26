SampShell_noninteractive_loaded=1

export SampShell_ROOTDIR="${SampShell_ROOTDIR:-"$(dirname "$0")"}"
export SampShell_EDITOR="${SampShell_EDITOR:-sublime4}"
export SampShell_TRASHDIR="${SampShell_TRASHDIR:-"$HOME/.Trash/.sampshell-trash"}"
export SampShell_TMPDIR="${SampShell_TMPDIR:-"$HOME/tmp"}"
export SampShell_HISTDIR="${SampShell_HISTDIR-"$SampShell_ROOTDIR"/.sampshell-history}" # Allow it to be empty.

# 'Add the path in'
case ":$PATH:" in
	*:"$SampShell_ROOTDIR/bin":*) ;;
	*) export PATH="$SampShell_ROOTDIR/bin:$PATH" ;;
esac

if [ -n "$ZSH_VERSION" ]; then
	setopt EXTENDED_GLOB # Add additoinal glob syntax in zsh
fi

## Parallelize a function by making a new job once per argument given
if type local >/dev/null 2>&1; then
	type parallelize_it >/dev/null 2>&1 || alias parallelize_it=SampShell_parallelize_it

	SampShell_parallelize_it () {
		local expand fn skipchr

		while :; do
			case "$1" in
				-h)
					cat <<-EOS >&2
						usage: $0 [options] [--] fn [args ...]
						options:
						   -e      use expansion on 'args'
						   -X      don't have a skipchar; overrides -x
						   -x[CHR] set the skipchar; if omitted defaults to 'x'
						   -fFUNC  sets the function to execute; if given, omit 'fn'
						           after '--'.
						This command executes 'fn' once for each arg as background job
					EOS
					return 255 ;;
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
fi

