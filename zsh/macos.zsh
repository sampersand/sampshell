## Macos-specific things

function  enable-wifi { networksetup -setairportpower en0 on }
function disable-wifi { networksetup -setairportpower en0 off }
function  toggle-wifi { disable-wifi; sleep 2; enable-wifi }


# Disable `xtrace` for each line, as apple does some setups with cwd and wahtnot
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
