### Ensure that `SampShell_ROOTDIR` is setup
# It should be set by the top-level `interactive.sh` file
: "${SampShell_ROOTDIR:?}"


if [ ! -d "$SampShell_ROOTDIR" ]; then
	cat <<WARNING >&2
[WARNING] \$SampShell_ROOTDIR ($SampShell_ROOTDIR) is not a directory.
[WARNING] This can cause some issues with other sampshell builtins.
WARNING
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

SampShell_command_exists parallelize_it || alias parallelize_it=SampShell_parallelize_it
