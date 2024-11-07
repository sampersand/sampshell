### Ensure that `SampShell_ROOTDIR` is setup
if [ -z "${SampShell_ROOTDIR+1}" ]; then
	export SampShell_ROOTDIR="$HOME/.sampshell"
	printf '[WARNING] Defaulting $SampShell_ROOTDIR to %s\n' "$SampShell_ROOTDIR" >&2
fi
if [ ! -e "${SampShell_ROOTDIR}" ]; then
	printf '[ERROR] SampShell_ROOTDIR does not exist; cannot setup sampshell: %s\n' "$SampShell_ROOTDIR" >&2
	return 1
fi

## Load the non-interactive config file in case it hasn't been loaded already.
if [ -z "$SampShell_POSIX_noninteractive_loaded" ]; then
	. "$SampShell_ROOTDIR/posix/non-interactive.sh" || return
fi

# Ensure that the posix bin is included.
case ":$PATH:" in
	*:"$SampShell_ROOTDIR/posix/interactive/bin":*) ;;
	*) export PATH="$SampShell_ROOTDIR/posix/interactive/bin:$PATH" ;;
esac

# Setup the config files
set -- "$SampShell_ROOTDIR"/posix/interactive/*.sh
until [ "$#" -eq 0 ]; do
	. "$1"
	shift
done
