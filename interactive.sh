# Make sure `SampShell_ROOTDIR` is set.
if [ -z "${SampShell_ROOTDIR-}" ]; then
	# If it's not set, and we're using ZSH, it's easy to find it.
	if [ -n "$ZSH_VERSION" ]; then
		SampShell_ROOTDIR="${0:P:h}"
	else
		# Looks like we don't know what shell we're using
		SampShell_ROOTDIR="$HOME/.sampshell"
		printf '[INFO] Defaulting $SampShell_ROOTDIR to %s\n' "$SampShell_ROOTDIR"
	fi
fi

if [ ! -d "$SampShell_ROOTDIR" ]; then
	printf '[FATAL] Not initializing SampShell: $SampShell_ROOTDIR does not exist, or isnt a dir: %s\n' \
		"${SampShell_ROOTDIR}" >&2
	return 1
fi

# Make sure it's exported
export SampShell_ROOTDIR

# Makesure `noninteractive` is also loaded, if it isnt for some reason.
[ -z "${SampShell_noninteractive_loaded-}" ] && . "$SampShell_ROOTDIR/non-interactive.sh"

# Source all POSIX-compliant stuff
SampShell_source_if_exists "$SampShell_ROOTDIR/posix/interactive.sh"

# If ZSH is defined, also source ZSH
[ -n "$ZSH_VERSION" ] && SampShell_source_if_exists "$SampShell_ROOTDIR/zsh/interactive.zsh"
