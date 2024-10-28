clean-zsh () {
	env -i "$@" ${TERM:+TERM="$TERM"} =zsh -f
}

clean-sh () {
	clean_sh ENV=${SampShell_ROOTDIR?}/interactive.sh
}
