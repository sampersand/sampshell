# Make sure `fc` is even around.
if SampShell_command_exists fc; then
	if [ -n "${SampShell_setup_history-}" ]; then
		# Set history argument sizes. I want them to be large so I can see them later.
		# how many lines to load into history originally
		HISTSIZE=1000000

		# Setup the histfile only if it doesnt exist; if it exists and is empty,
		# do not set it up.
		if [ -z "${HISTFILE+1}" ]; then
			HISTFILE=${SampShell_HISTDIR:-"$HOME"}/.sampshell_history
		fi
	fi

	# Sets up `history` and `h` aliases
	SampShell_command_exists history || alias history='fc -l'
	alias h=history
fi
