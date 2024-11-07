# Clear the screen; also uses the `clear` command if it exists
cls () {
	SampShell_command_exists clear && { clear || return; }
	printf '\ec\e[3J'
}

# Sets the prompt unless `SampShell_dont_set_PS1` is explicitly set
if [ -z "${SampShell_dont_set_PS1-}" ]; then
	export PS1='[?$? !!!] $0 ${PWD##"${HOME:+"$HOME"/}"} $ '
fi
