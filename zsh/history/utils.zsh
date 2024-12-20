typeset -aU zshaddhistory_functions

zshaddhistory_functions[1,0]=(SampShell-custom-ignore-history)

typeset -g -aU SampShell_history_ignore_patterns
function SampShell-custom-ignore-history {
	# N.B. need `!=` to return 1 when we _should_ ignore the command.
	[[ ${1%$'\n'} != ${(j:|:)~SampShell_history_ignore_patterns} ]]
}

function history-ignore-command {
	SampShell_history_ignore_patterns+=("${(q)^@}(|[[:blank:]]*)")
}

function history-ignore-glob { SampShell_history_ignore_patterns+=($@) }


history-ignore-command pc
history-ignore-command cpc
history-ignore-command h
