#!sh

##
# This is a helper script that can be sourced for shells which don't support
# both interactive and non-interactive shell scripts.
##

# Assume we're not using zsh (as it has both interactive and noninteractive)
: "${SampShell_ROOTDIR:=$HOME/.sampshell}"
if ! test -d "$SampShell_ROOTDIR"
then
	printf '[FATAL] Unable to initialize SampShell: $SampShell_ROOTDIR does not exist/isnt a dir: %s\n' \
		"${SampShell_ROOTDIR}" >&2
	return 1
fi

# Load the init files
. "$SampShell_ROOTDIR/init"

# Load the init-interactive files
case $- in
	*i*) . "$SampShell_ROOTDIR/init-interactive"
esac
