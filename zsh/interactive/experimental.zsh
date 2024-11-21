## Options I'm not sure if I want to set or not.
[[ -n $ENV ]] && emulate sh -c '. "${(e)ENV}"'

: "${REPORTTIME=4}" # Print the duration of commands that take more than 4s of CPU time
# DIRSTACKSIZE=30   # I just started using dirstack more, if it ever grows unwieldy I can set this.

setopt EXTENDED_HISTORY       # (For fun) When writing cmds, write their start time & duration too.
setopt COMPLETE_IN_WORD
setopt CORRECT              # Correct commands when executing.
setopt RM_STAR_WAIT         # Wait 10 seconds before accepting the `y` in `rm *`
setopt CSH_JUNKIE_LOOPS     # Allow loops to end in `end`; only loops tho not ifs
setopt CASE_GLOB CASE_PATHS # Enable case-insensitive globbing, woah!
setopt NO_FLOW_CONTROL      # Modern terminals dont need control flow lol
# WORDCHARS=$WORDCHARS # ooo, you can modify which chars are for a word in ZLE

## Defaults that probably shoudl eb set
unsetopt IGNORE_EOF      # In case it was set, as I use `ctrl+d` to exit a lot.
unsetopt GLOB_SUBST SH_GLOB # defaults that should be set

## 
# TMPPREFIX=$SampShell_TMPDIR/.zsh/ # todo; shoudl this be set to SampShell_TMPDIR?

# Disable `xtrace` for each line, as apple does some setups with cwd and wahtnot
# which catches us offguard.
if [[ $VENDOR == apple ]]; then
	typeset +x -gH _SampShell_was_xtrace_on

	function _SampShell_disable_xtrace {
		_SampShell_was_xtrace_on=$options[xtrace]
		trap 'unsetopt xtrace' EXIT
	}
	function _SampShell_enable_xtrace {
		trap '[[ $_SampShell_was_xtrace_on = on ]] && setopt xtrace' EXIT
	}

	typeset -aU precmd_functions preexec_functions

	precmd_functions[1,0]=_SampShell_disable_xtrace
	preexec_functions+=(_SampShell_enable_xtrace)
fi

