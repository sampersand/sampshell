#### Basic SampShell definitions for _all_ POSIX-complaint shells
# This file is intended to be `.`able from anywhere, be it from interactive
# shells, or from within scripts.
#
# This file is strictly POSIX-compliant, as it'll be loaded for every shell.
#
#
# Order of Operations
# ===================
#   1. Create `Sampshell_XXX` variables (if they dont exist), and export them.
#   2. Setup `SampShell_xxx functions.
#   3. If `$SampShell_ROOTDIR` is set, add POSIX-compliant utilites to `$PATH`.
#
#
# Required Variables
# ==================
# This script makes no assumptions about what variables are present. When
# creating `SampShell_XXX` variables, unset (and empty for some; see their
# definitions) variables are populated with a default value.
#
# The `$SampShell_ROOTDIR` variable is not set by this script. If it was set
# before this script, it is used for adding POSIX-compliant utilites to `$PATH`
#
#
# Safety
# ======
# Since this is intended to be `.`able from within scripts, numerous safe
# been done:
#
#   * All variables and functions are prefixed with `SampShell_` to prevent
#     naming collisions.
#   * No `alias`es are added.
#   * The `set -eux` options from POSIX are respected, in case they're present
#
# Additionally, to make it easy to transfer this file around, and paste it
# directly into terminals, some other things are done:
#
#   * Line-continuation (`\` at the end of a line) is never done.
#   * Lines are limited to 80 characters when possible
#   * Only spaces are used for indentation (makes it easy to copy-paste)
####

################################################################################
#                           Exported Shell Variables                           #
################################################################################

# Note regardless of whether we set the value to a default, we always export the
# variables. This ensures that we can see them from within other utilities, like
# our POSIX ones.

# The editor to open files with via the `subl` command
if [ -z "${SampShell_EDITOR-}" ]; then
	SampShell_EDITOR=sublime4
fi
export SampShell_EDITOR

# Where all files that sampshell uses should by default be placed at.
if [ -z "${SampShell_GENDIR-}" ]; then
	SampShell_GENDIR="${HOME:-/tmp}" # Wack, who wouldnt have `$HOME` set
fi
export SampShell_GENDIR

# Where files moved from the `trash` command should go
if [ -z "${SampShell_TRASHDIR-}" ]; then
	SampShell_TRASHDIR="$SampShell_GENDIR/.sampshell-trash"
fi
export SampShell_TRASHDIR

# Where temporary files by SampShell go.
if [ -z "${SampShell_TMPDIR-}" ]; then
	SampShell_TMPDIR="$SampShell_GENDIR/tmp"
fi
export SampShell_TMPDIR

# Where history files go. Note that unlike other variables, a default won't be
# added if `$SampShell_HISTDIR` is empty, as that indicates no history.
if [ -z "${SampShell_HISTDIR+1}" ]; then
	SampShell_HISTDIR="$SampShell_GENDIR/.sampshell-history"
fi
export SampShell_HISTDIR

# Whether or not SampShell should be verbose. If it's unset, then we set it to
# true if we're in interactive mode.
if [ -z "${SampShell_VERBOSE+1}" ]; then
	case "$-" in
		*i*) SampShell_VERBOSE=1 ;;
		*) SampShell_VERBOSE= ;;
	esac
fi
export SampShell_VERBOSE

# Whether to enable `set -o xtrace` in scripts. It's important that this is
# exported, so that scripts can see it.
if [ -z "${SampShell_TRACE-}" ]; then
	SampShell_TRACE=
fi
export SampShell_TRACE


################################################################################
#                                  Functions                                   #
################################################################################

## Logs a message if `$SampShell_VERBOSE` is enabled; It forwards all its args
# to printf, except it adds a newline to the end of the format argument.
SampShell_log () {
	[ -z "${SampShell_VERBOSE-}" ] && return 0
	SampShell_scratch="${1:?need a fmt}"
	shift
	set -- "$SampShell_scratch\\n" "$@"
	unset -v SampShell_scratch
	printf -- "$@"
}

## Same as `.`, except it only sources files if the first argument exists; will
# return `0` if the file doesn't exist.
SampShell_dot_if_exists () {
	if [ -e "${1:?need file to source}" ]; then
		. "$@"
	else
		SampShell_log 'Not sourcing non-existent file: %s' "$1"
	fi

	return 0
}

## Returns whether or not the given command exists.
SampShell_command_exists () {
	command -V "${1:?need command to check}" >/dev/null 2>&1
}

## Adds its argument to the start of '$PATH' if it doesnt already exist; same as
# PATH="$PATH:$1", except it handles the case when PATH does't exist, and makes
# sure to not add $1 if it already exists; note that this doesn't export PATH.
# Notably this doesn't export the path.
SampShell_add_to_path () {
	case ":${PATH-}:" in
		*:"${1:?need a path to add to PATH}":*) : ;;
		*) PATH="$1${PATH:+:}$PATH" ;;
	esac
}

## CD's to the directory containing a file
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

	SampShell_scratch=$(dirname -- "$1" && printf x) || {
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
fi


################################################################################
#                                  Setup PATH                                  #
################################################################################

## Add POSIX-compliant bin scripts to the `$PATH`.
# They're only added if `$SampShell_ROOTDIR` is set. A warning is logged if the
# `$SampShell_ROOTDIR` is not a directory (ie doesn't exist or is a file), but
# the scripts are still added.
#
# Ensure also ensures that that `$SampShell_ROOTDIR/posix/bin` is only added
# once, so as to not pollute the `$PATH`
#
# Note that we allow `$SampShell_ROOTDIR` to be empty, in case the files are
# stored under `/posix/bin`.
if [ -n "${SampShell_ROOTDIR+1}" ]; then
	if ! [ -d "$SampShell_ROOTDIR/posix/bin" ]; then
		SampShell_log '[WARN] POSIX bin location (%s/posix/bin) does not exist; still adding it to $PATH though' "$SampShell_ROOTDIR"
	fi

	SampShell_add_to_path "$SampShell_ROOTDIR/posix/bin"
	export PATH
fi
