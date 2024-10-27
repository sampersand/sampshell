for file in "${0:P:h}"/non-interactive/*.zsh; do
	source $file
done

setopt EXTENDED_GLOB          # Add additional glob syntax in zsh
setopt NO_IGNORE_CLOSE_BRACES # Allow `}` to also be a `;`
setopt GLOB_STAR_SHORT        # **.c is an alias for **/*.c
setopt NO_ALIAS_FUNC_DEF
