# This  tries to toggle `set -x` so as to not display it for "hook" commands, like Terminal's
# `update_terminal_cwd`. It came from a time where I'd do `set -x` on the command line and play
# around with ZSH. I no longer really need that (the `-x` command I made does everything I used to
# do), and I more often than not find myself doing `unset _SampShell_disable_xtrace`, as I want
# to benchmark things.


# Disable `xtrace` for each line, as apple does some setups with cwd and whatnot
# which catches us offguard.
if [[ $TERM_PROGRAM == Apple_Terminal ]] then

	function _SampShell_disable_xtrace {
		typeset -g _SampShell_was_xtrace_on=$options[xtrace]
		trap 'unsetopt xtrace' EXIT
	}

	function _SampShell_enable_xtrace {
		trap '[[ $_SampShell_was_xtrace_on = on ]] && setopt xtrace' EXIT
	}

	typeset -aU precmd_functions preexec_functions

	precmd_functions[1,0]=_SampShell_disable_xtrace
	preexec_functions+=(_SampShell_enable_xtrace)
fi
