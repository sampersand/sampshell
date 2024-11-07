# Make sure `SampShell_ROOTDIR` is set.
if [ -z "${SampShell_ROOTDIR-}" ]; then
	# If it's not set, and we're using ZSH, it's easy to find it.
	if [ -n "$ZSH_VERSION" ]; then
		SampShell_ROOTDIR="${0:P:h}"
	else
		# Looks like we don't know what shell we're using; hope it exists here.
		SampShell_ROOTDIR="$HOME/.sampshell"
		printf '[INFO] Defaulting $SampShell_ROOTDIR to %s\n' "$SampShell_ROOTDIR"
	fi
fi

if [ ! -d "$SampShell_ROOTDIR" ]; then
	printf '[FATAL] Not initializing SampShell: \$SampShell_ROOTDIR does not exist, or isnt a dir: %s\n' \
		"${SampShell_ROOTDIR}" >&2
	return 1
fi

export SampShell_ROOTDIR # make sure it's exported

SampShell_noninteractive_loaded=1

# Source the posix stuff
[ -e "$SampShell_ROOTDIR/setup.sh" ] && . "$SampShell_ROOTDIR/setup.sh"
[ -n "$ZSH_VERSION" ] && [ -e "$SampShell_ROOTDIR/zsh/non-interactive.sh" ] && . "$SampShell_ROOTDIR/zsh/non-interactive.zsh"
