# Ensure '$SampShell_ROOTDIR' is set
if [ -z "${SampShell_ROOTDIR+1}" ]; then
	echo "[ERROR] Cannot initialize SampShell: \$SampShell_ROOTDIR is not set" >&2
	return 1
fi

SampShell_POSIX_noninteractive_loaded=1
export SampShell_ROOTDIR="${SampShell_ROOTDIR:?}" # Make sure this is set!

# Ensure that the posix bin is included.
case ":$PATH:" in
	*:"$SampShell_ROOTDIR"/posix/non-interactive/bin:*) ;;
	*) export PATH="$SampShell_ROOTDIR/posix/non-interactive/bin:$PATH" ;;
esac

# Load additional config files
set -- "$SampShell_ROOTDIR"/posix/non-interactive/*.sh
until [ "$#" = 0 ]; do
	. "$1"
	shift
done
