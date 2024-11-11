## Helper script to run both `env` and `interactive`
# This is intended for shells that don't support multiple startup files for
# interactive or non-interactive instances.
##

# Make sure `SampShell_ROOTDIR` is set; THIS IS COPIED FROM `env.sh` DIRECTLY.
if [ -z "${SampShell_ROOTDIR-}" ]; then
	# If we're using ZSH, just use the builtin `${0:P:h}` to find it.
	if [ -n "${ZSH_VERSION-}" ]; then
		# We need to use `eval` in case shells don't understand `${0:P:h}`.
		eval 'SampShell_ROOTDIR="${0:P:h}"'
	elif [ -n "${BASH_VERSION-}" ] && [ -n "${BASH_SOURCE-}" ]; then
		SampShell_ROOTDIR=$(dirname -- "$BASH_SOURCE" && printf x) || return
		SampShell_ROOTDIR=${SampShell_ROOTDIR#?x}

	# If we're not interactive, then just return 1
	elif case "$-" in *i*) false; esac; then
		return 1

	# We are interactive, default it and warn
	else
		# Whelp, we can't rely on `$0`, let's just guess and hope?
		SampShell_ROOTDIR="$HOME/.sampshell"
		printf '[INFO] Defaulting $SampShell_ROOTDIR to %s\n' \
			"$SampShell_ROOTDIR" >&2
	fi
fi

# Load `env``
. "${SampShell_ROOTDIR}/env.sh" || return

# Load `interactive`` if we're interactive
case "$-" in
	*i*) . "${SampShell_ROOTDIR}/interactive.sh" || return
esac
