# Clear the screen; also uses the `clear` command if it exists
cls () {
	SampShell_command_exists clear && { clear || return; }
	printf '\ec\e[3J'
}

magenta=$(printf %b '\033[35m')
cyan=$(printf %b '\033[36m')
blue=$(printf %b '\033[34m')
green=$(printf %b '\033[32m')
red=$(printf %b '\033[31m')
bold=$(printf %b '\033[1m')
nobold=$(printf %b '\033[0m')
underline=$(printf %b '\033[4m')
nounderline=$(printf %b '\033[24m')
reset=$(printf %b '\033[39m')

# echo "$blue[$reset?0 $blue]$reset'

PS1='[?$? !!!] ${0##*/} ${PWD##"${HOME:+"$HOME"/}"} $ '

PS1="$bold$blue[$reset$magenta?\$? $green!!!$blue$bold] $reset"
