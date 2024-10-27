if [ -z "${SampShell_ROOTDIR+1}" ]; then
	if [ -n "$ZSH_VERSION" ]; then
		export SampShell_ROOTDIR="${0:P:h}"
	else
		echo "[ERROR] Cannot initialize SampShell: \$SampShell_ROOTDIR is not set" >&2
		return 1
	fi
fi

. "$SampShell_ROOTDIR/posix/non-interactive.sh"

[ -n "$ZSH_VERSION" ] && . "$SampShell_ROOTDIR/zsh/non-interactive.zsh"
