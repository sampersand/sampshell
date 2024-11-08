# Have the ability of opting-out of setting up history, in case custom history
# stuff is already happening.
if [ -n "${SampShell_always_setup_history-}" ]; then
	unset HISTSIZE HISTFILE # TODO: is this the best strategy?
	# HISTSIZE=
	# HISTFILE=
fi

# Only setup things if they don't exist; if they exist and are empty, that can
# be intentional.
[ -z "${HISTSIZE+1}" ] && HISTSIZE=500 # How many history entries to keep
[ -z "${HISTFILE+1}" ] && HISTFILE=${SampShell_HISTDIR:-$HOME}/.sampshell_history

# Sets up `history` and `h` aliases
SampShell_command_exists history || alias history='fc -l'
alias h=history
