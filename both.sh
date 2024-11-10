## Helper script to run both `env` and `interactive`
# This is intended for shells that don't support multiple startup files for
# interactive or non-interactive instances.
#
# Note that this script is not as bulletproof with regards to determining the
# `$SampShell_ROOTDIR` as `env` is; when in doubt, just source that first.
##

# Assume we're not using zsh (as it has both interactive and noninteractive)
: "${SampShell_ROOTDIR:=$HOME/.sampshell}"
if ! [ -d "${SampShell_ROOTDIR}" ]; then
	printf '[FATAL] Unable to initialize SampShell: $SampShell_ROOTDIR does not exist/isnt a dir: %s\n' \
		"${SampShell_ROOTDIR}" >&2
	return 1
fi

# Load `env``
. "${SampShell_ROOTDIR}/env.sh" || return

# Load `interactive`` if we're interactive
case "$-" in
	*i*) . "${SampShell_ROOTDIR}/interactive.sh" || return
esac
