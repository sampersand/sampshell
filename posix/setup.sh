###
# Basic SampShell definitions for _all_ POSIX-complaint shells, in both
# interactive and non-interactive mode.
#
# It's expected that this file can be `.`'d at any point, so only the bare-
# minimum setup is done. This also means that all declarations start with the
# prefix `SampShell_` so as to not conflict with any extant identifiers.
#
# The file also accepts a single argument, which will be used as the value
# for `SampShell_ROOTDIR`; if an argument isn't given, `SampShell_ROOTDIR` is
# left empty.
###

################################################################################
#                        Process Command-Line Arguments                        #
################################################################################

# If an argument is given, then set `SampShell_ROOTDIR` to it.
case "$#" in
	0) ;;
	1) SampShell_ROOTDIR="$1" ;;
	*) echo "[FATAL] only 1 argument is accepted" >&2; return 1 ;;
esac

: "${SampShell_ROOTDIR=""}" # Ensure it's set so `set -u` won't fail
export SampShell_ROOTDIR

################################################################################
#                                  Setup PATH                                  #
################################################################################

# If `$SampShell_ROOTDIR` is set, then ensure that `$PATH` includes the
# `$SampShell_ROOTDIR/posix/bin` folder. (But only once, so as to not pollute
# it). We add `:`s to the both side of `$PATH` to simplify the case conditions.
[ -n "${SampShell_ROOTDIR}" ] && case ":${PATH-}:" in
	*:"$SampShell_ROOTDIR/posix/bin":*) : ;; # It already exists, don't add it.
	*) PATH="$SampShell_ROOTDIR/posix/bin:$PATH"; export PATH ;;
esac

################################################################################
#                           Exported Shell Variables                           #
################################################################################

# The editor to open files with via the `subl` command
: "${SampShell_EDITOR:=sublime4}"
export SampShell_EDITOR

# Where all files that sampshell uses should by default be placed at.
: "${SampShell_GENERATED_DIR:="$HOME"}"
export SampShell_GENERATED_DIR

# Where files moved from the `trash` command should go
: "${SampShell_TRASHDIR:="$SampShell_GENERATED_DIR/.sampshell-trash"}"
export SampShell_TRASHDIR

# Where temporary files by SampShell Go.
: "${SampShell_TMPDIR:="$SampShell_GENERATED_DIR/.sampshell-tmp"}"
export SampShell_TMPDIR

# Where history files go; note that this is allowed to be empty, which means
# we shouldn't be storing history
: "${SampShell_HISTDIR="$SampShell_GENERATED_DIR/.sampshell-history"}"
export SampShell_HISTDIR

################################################################################
#                                  Functions                                   #
################################################################################

# Note we `unalias` these in case they're already aliased for some reason, and
# do `|| :` in case the alias doesn't exit and `set -e` is enabled.

# Same as `.`, except it only sources files if the first argument exists. 
unalias SampShell_source_if_exists >/dev/null 2>&1 || :
SampShell_source_if_exists () {
	[ -e "${1:?'need file to source'}" ] && . "$@"
}

# Returns whether or not the given command exists.
unalias SampShell_command_exists >/dev/null 2>&1 || :
SampShell_command_exists () {
	command -V "${1:?'need command to check'}" >/dev/null 2>&1
}

# CD's to the directory containing a file
unalias SampShell_cdd >/dev/null 2>&1 || :
SampShell_cdd () {
	if [ "$#" -eq 2 ] && [ "$1" = -- ]; then
		shift
	elif [ "$#" -ne 1 ] || [ "$1" = -h ] || [ "$1" = --help ] || [ "$1" = -- ]
	then
		# Set exit status, and where to redirect
		if [ "$1" = -h ] || [ "$1" = --help ]; then
			set -- 0
		else
			set -- 1
		fi

		echo "usage: cdd [-h/--help] [--] directory" >&"$((1 + $1))"
		return "$1"
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
	unalias SampShell_parallelize_it >/dev/null 2>&1 || :
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
fi

