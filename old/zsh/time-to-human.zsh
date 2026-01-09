# This was used in the prompt previously; but we only need minutes really
function prompt_sampshell_time_to_human {
	float now=$1

	if (( !PROMPT_SAMPSHELL_LAST_EXEC_TIME )) return
	float diff='now - PROMPT_SAMPSHELL_LAST_EXEC_TIME'

	# Make it red if the difference is more than 3s
	psvar[prompt_sampshell_var_time_diff]=
	if (( diff > 1 )) psvar[prompt_sampshell_var_time_diff]=1

	float -F5 seconds='diff % 60'
	integer minutes='(diff /= 60) % 60'
	integer hours='(diff /= 60) % 24'
	integer days='(diff /= 24)'

	local tmp
	if (( days )) tmp+=${days}d
	if (( hours )) tmp+=${tmp:+ }${hours}h
	if (( minutes )) tmp+=${tmp:+ }${minutes}m
	psvar[prompt_sampshell_var_time_str]=${tmp:+ }${seconds}s

	PROMPT_SAMPSHELL_LAST_EXEC_TIME=
}
