clean-zsh () {
	env -i "$@" ${TERM:+TERM="$TERM"} =zsh -f
}
