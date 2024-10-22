clean-zsh () {
	env -i "$@" ${TERM:+TERM="$TERM"} =zsh -f
}

setopt NO_IGNORE_CLOSE_BRACES # Allow `}` to also be a `;`
setopt GLOB_STAR_SHORT        # **.c is an alias for **/*.c
