if [ -z "${SampShell_ROOTDIR+1}" ]; then
	echo "[ERROR] Cannot initialize SampShell: \$SampShell_ROOTDIR is not set" >&2
	exit 1
fi


. "$SampShell_ROOTDIR/posix/interactive.sh"

[ -n "$ZSH_VERSION" ] && . "$SampShell_ROOTDIR/zsh/interactive.zsh"
