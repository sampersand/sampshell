###
# Basic SampShell definitions for _all_ interactive POSIX-complaint shells.
#
# It's expected that this file will be `.`'d at the start of a shell instance,
# but it is possible that might be `.`'d later (such as if `source`da
# It's expected that this file can be `.`'d at any point, so only the bare-
# minimum setup is done. This also means that all declarations start with the
# prefix `SampShell_` so as to not conflict with any extant identifiers.
#
# The file also accepts a single argument, which will be used as the value
# for `SampShell_ROOTDIR`; if an argument isn't given, `SampShell_ROOTDIR` is
# left empty.
###

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
