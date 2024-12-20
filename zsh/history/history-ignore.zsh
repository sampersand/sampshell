## List of patterns to ignore
typeset -g -a -U -H _SampShell_histignore_patterns

## Prepend to the start of `zshaddhistory_functions` so we go after "record-every-command"
zshaddhistory_functions[1,0]=(_SampShell-histignore)

## Ignore commands that match any of `_SampShell_histignore_patterns`.
function _SampShell-histignore {
	line=${1%%[[:space:]]} # Trim trailing whitespace, also including the `\n`
	line=${1##[[:space:]]} # Trim leading whitespace

	# Match against all the commands
	# NOTE: `!=` is used because we return `1` when we _dont_ want to record the command.
	[[ $line != ${(j:|:)~_SampShell_histignore_patterns} ]]
}

## Ignore lines that start with this commands arguments.
function history-ignore-command {
	if [[ $1 == -h || $# == 0 ]] then
		>&2 print "usage: $0 command [...commands]"
		>&2 print
		>&2 print "Don't save invocations of 'command' in history"
		return 1
	fi

	# NOTE: Make sure to quote the command names so they won't be interpreted as patterns.
	_SampShell_histignore_patterns+=( "${(q)^@}(|[[:space:]]*)" )
}


## Adds its arguments to the list of lines to ignore
function history-ignore-glob {
	if [[ $1 == -h || $# == 0 ]] then
		>&2 print "usage: $0 glob [...globs]"
		>&2 print
		>&2 print "Don't save lines (stripped of leading and trailing whitespace) that"
		>&2 print "match glob exactly."
		return 1
	fi

	## NOTE: We wrap in `()` as a defensive measure to make sure patterns dont escape.
	_SampShell_histignore_patterns+=( "(${^@})" )
}
