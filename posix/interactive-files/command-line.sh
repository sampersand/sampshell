# Clear the screen; also uses the `clear` command if it exists
cls () {
	SampShell_command_exists clear && { clear || return; }
	printf '\ec\e[3J'
}

if [ -z "$SampShell_colours" ]; then
	PS1='[!!! | ?$?] ${PWD##"${HOME:+"$HOME"/}"} ${0##*/}$ '
else
	echo "TODO"
	magenta=$(printf %b '\033[35m')
	cyan=$(printf %b '\033[36m')
	yellow=$(printf %b '\033[93m')
	grey=$(printf %b '\033[90m')
	blue=$(printf %b '\033[34m')
	green=$(printf %b '\033[32m')
	red=$(printf %b '\033[31m')
	bold=$(printf %b '\033[1m')
	nobold=$(printf %b '\033[0m')
	underline=$(printf %b '\033[4m')
	nounderline=$(printf %b '\033[24m')
	reset=$(printf %b '\033[39m')

	PS1="$bold$blue[$nobold$cyan\$(date +'%_I:%M:%S %p')$reset $underline!$nounderline $bold$blue|$nobold$reset $magenta\$?$bold$blue]$nobold$reset"
	PS1="$PS1 $yellow\${PWD##\"\${HOME:+\"\$HOME\"/}\"}$reset"
	PS1="$PS1 \${0##*/}$grey\$$reset "
fi
