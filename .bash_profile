# Ensure we're not disabled
if (( $SampShell_DISABLED )) then
	return
fi

# Setup `SampShell_ROOTDIR` to be the directory containing this file, if it's not already set.
if [[ -z ${SampShell_ROOTDIR-} ]] then
	SampShell_ROOTDIR=$(dirname -- "$BASH_SOURCE" && printf x) || return
	SampShell_ROOTDIR=$(realpath -- "${SampShell_ROOTDIR%?x}" && printf x) || return
	SampShell_ROOTDIR=${SampShell_ROOTDIR%?x}
fi

. "$SampShell_ROOTDIR/.profile"

if [[ "$(uname)" = Darwin ]] then
	BASH_SILENCE_DEPRECATION_WARNING=1
fi
