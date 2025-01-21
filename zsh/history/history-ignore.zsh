## ... overview ...
# This is different from `HISTORY_IGNORE` as that's only when commands are being saved.
#
# (NOTE: This could have used `zstyles` but then it'd behard to dynamically add new commands.
# zstyle :sampshell:history:ignore:p true

## The list of patterns to ignore.
# - `-g +x`: Globally visible within this shell, but not exported to other programs.
# - `-aU`  : Declares it as an array that ensures its arguments are always unique.
# - `-H`   : Hide it when `typeset`ting, as it's a private variable and others dont need it.
typeset -g +x -aU -H _SampShell_histignore_patterns

## Prepend to the start of `zshaddhistory_functions` so we go before "record-every-command"
zshaddhistory_functions[1,0]=(_SampShell-history-ignore-hook)

## Ignore commands that match any of `_SampShell_histignore_patterns`.
function _SampShell-history-ignore-hook {
	# Reset ZSH to default options, and enable EXTENDED_GLOB if it wasn't previously enabled.
	emulate -L zsh -o EXTENDED_GLOB

	# Strip leading and trailing whitespace, including the trailing `\n`
	local line=$1
	line=${line%%[[:space:]]#}
	line=${line##[[:space:]]#}

	# Match against all the commands. NOTE: `!=` is used because we return `1` when we _dont_
	# want to record the command.
	[[ $line != ${(j:|:)~_SampShell_histignore_patterns} ]]
}

## Ignore lines that start with this commands arguments.
function {SampShell-,}history-ignore-command {
	emulate -L zsh # Reset ZSH to default options for this function

	if [[ $1 == -h || $# == 0 ]] then
		print >&2 "usage: $0 command [...commands]"
		print >&2
		print >&2 "Don't save invocations of 'command' in history"
		return 1
	fi

	# (NOTE: The names are quoted so they won't be interpreted as patterns)
	_SampShell_histignore_patterns+=( "${(q)^@}(|[[:space:]]*)" )
}


## Adds its arguments to the list of lines to ignore
function {SampShell-,}history-ignore-glob {
	emulate -L zsh # Reset ZSH to default options for this function

	if [[ $1 == -h || $# == 0 ]] then
		print >&2 "usage: $0 glob [...globs]"
		print >&2
		print >&2 "Don't save lines (stripped of leading and trailing whitespace) that"
		print >&2 "match glob exactly."
		return 1
	fi

	## NOTE: We wrap in `()` as a defensive measure to make sure patterns dont escape.
	_SampShell_histignore_patterns+=( "(${^@})" )
}
