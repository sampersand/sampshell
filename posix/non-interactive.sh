# Ensure '$SampShell_ROOTDIR' is set, or default it.
if [ -z "${SampShell_ROOTDIR+1}" ]; then
	echo "[ERROR] Cannot initialize SampShell: \$SampShell_ROOTDIR is not set" >&2
	return 1
fi

SampShell_POSIX_noninteractive_loaded=1

# Default variables that should always be visible
export SampShell_ROOTDIR="${SampShell_ROOTDIR:?}"
export SampShell_EDITOR="${SampShell_EDITOR:-sublime4}"
export SampShell_TRASHDIR="${SampShell_TRASHDIR:-"$HOME/.Trash/.sampshell-trash"}"
export SampShell_TMPDIR="${SampShell_TMPDIR:-"$HOME/tmp"}"
export SampShell_HISTDIR="${SampShell_HISTDIR-"$SampShell_ROOTDIR"/.sampshell-history}" # Allow it to be empty.

# Ensure that the posix bin is included.
case ":$PATH:" in
	*:"$SampShell_ROOTDIR/posix/bin":*) ;;
	*) export PATH="$SampShell_ROOTDIR/posix/bin:$PATH" ;;
esac

set -- "$SampShell_ROOTDIR"/posix/non-interactive/*

until [ "$#" = 0 ]; do
	. "$1"
	shift
done
