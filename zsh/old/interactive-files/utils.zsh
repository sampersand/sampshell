function clean-zsh {
	env -i "$@" ${TERM:+TERM="$TERM"} =zsh -f
}

function clean-sh {
	clean_sh ENV=${SampShell_ROOTDIR?}/interactive.sh
}

function zreload {
	[ -e "${ZDOTDIR:-$HOME}/.zshenv" ] && source "${ZDOTDIR:-$HOME}/.zshenv"
	[ -e "${ZDOTDIR:-$HOME}/.zshrc" ]  && source "${ZDOTDIR:-$HOME}/.zshrc"
}
