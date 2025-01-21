## List of patterns to ignore
typeset -g -a -U -H _SampShell_histignore_patterns

## Prepend to the start of `zshaddhistory_functions` so we go before "record-every-command"
zshaddhistory_functions[1,0]=(_SampShell-histignore)

## Ignore commands that match any of `_SampShell_histignore_patterns`.
function _SampShell-histignore {
	# Add extended globs in if they weren't previously
	setopt LOCAL_OPTIONS EXTENDED_GLOB

	# Strip leading and trailing whitespace, including the trailing `\n`
	local line=$1
	line=${line%%[[:space:]]#}
	line=${line##[[:space:]]#}

	# Match against all the commands. NOTE: `!=` is used because we return `1` when we _dont_
	# want to record the command.
	[[ $line != ${(j:|:)~_SampShell_histignore_patterns} ]]
}

## Ignore lines that start with this commands arguments.
function history-ignore-command {
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
function history-ignore-glob {
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
