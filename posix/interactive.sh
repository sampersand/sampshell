echo "todo: set +f or something, idk"

if [ -z "${SampShell_ROOTDIR+1}" ]; then
	export SampShell_ROOTDIR="$HOME/.sampshell"
	echo "[WARN] Defaulting \$SampShell_ROOTDIR to $SampShell_ROOTDIR." >&2
fi

# Load the non-interactive config file in case it hasn't been loaded already.
if [ -z "$SampShell_POSIX_noninteractive_loaded" ]; then
	. "${SampShell_ROOTDIR:?}/posix/non-interactive.sh" || return
fi

# Ensure that the posix bin is included.
case ":$PATH:" in
	*:"$SampShell_ROOTDIR/posix/interactive/bin":*) ;;
	*) export PATH="$SampShell_ROOTDIR/posix/interactive/bin:$PATH" ;;
esac

set -- "$SampShell_ROOTDIR"/posix/interactive/*
until [ "$#" = 0 ]; do
	. "$1"
	shift
done
