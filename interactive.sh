if [ -z "${SampShell_ROOTDIR+1}" ]; then
	if [ -n "$ZSH_VERSION" ]; then
		export SampShell_ROOTDIR="${0:P:h}"
	else
		export SampShell_ROOTDIR="$HOME/.sampshell"


		if [ -d "$SampShell_ROOTDIR" ]; then
			echo "[WARN] Defaulting \$SampShell_ROOTDIR to $SampShell_ROOTDIR." >&2
		else
			echo "[ERROR] Not initializing SampShell: \$SampShell_ROOTDIR is not set" \
				  "and the default ($SampShell_ROOTDIR) doesn't exist/isn't a dir" >&2
			return 1
		fi
	fi
fi

. "$SampShell_ROOTDIR/posix/interactive.sh"

[ -n "$ZSH_VERSION" ] && . "$SampShell_ROOTDIR/zsh/interactive.zsh"
