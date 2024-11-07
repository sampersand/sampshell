### Ensure that `SampShell_ROOTDIR` is setup
# It should be set by the top-level `interactive.sh` file
: "${SampShell_ROOTDIR:?}"

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
