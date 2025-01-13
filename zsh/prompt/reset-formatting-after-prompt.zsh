#!zsh

# Sometimes the prompt gets `CTRL+C`'d in the middle of doing stuff, and it doesn't reset
# its colours. This forces them to be reset always.

typeset -aU preexec_functions
preexec_functions+=(_SampShell-preexec-clear-formatting)

# Reset formatting.
function _SampShell-preexec-clear-formatting {
	# (TODO: is this right: though i cant figure out how to unset background colours)
	print -nP '%b%u%s%f'
}


