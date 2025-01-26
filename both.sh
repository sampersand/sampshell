## Helper script to run both `env` and `interactive` as needed
# This is intended for shells that don't support multiple startup files for
# interactive or non-interactive instances, or if you don't know what to put
# where.
##

# Make sure `SampShell_ROOTDIR` is set.
if [ -n "${SampShell_ROOTDIR-}" ]; then
	# Already setup, nothing to do.
	:
elif [ -n "${ZSH_VERSION-}" ]; then
	# ZSH: just use the builtin `${0:P:h}` to find it
	SampShell_ROOTDIR=${0:P:h}
elif [ -n "${BASH_SOURCE-}" ]; then
	# BASH: Use `BASH_SOURCE`
	SampShell_ROOTDIR=$(dirname -- "$BASH_SOURCE" && printf x) || return
	SampShell_ROOTDIR=${SampShell_ROOTDIR%?x}
elif case $- in *i*) false; esac; then
	# Non-interactive: Error, just return 1.
	return 1
else
	# We are interactive, guess a default (hope it works) and warn.
	SampShell_ROOTDIR="$HOME/.sampshell"
	printf >&2 '[WARN] Default $SampShell_ROOTDIR to %s\n' "$SampShell_ROOTDIR"
fi

# Load `env` unconditionally.
. "${SampShell_ROOTDIR}/env.sh" || return

# Load `interactive` if we're an interactive shell.
case "$-" in *i*)
	. "${SampShell_ROOTDIR}/interactive.sh" || return
esac
