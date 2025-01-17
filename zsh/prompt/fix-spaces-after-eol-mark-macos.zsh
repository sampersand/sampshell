#!zsh


# (This is a failed experiment, because it will swallow characters that're typed before the prompt is written)

# ZSH by default helpfully prints out an inverted `%` when an incomplete line is printed. However,
# it ends up adding _lots_ of spaces to stdout, which makes it annoying to copy on Terminal in
# MacOS. (This is usually correct, as race conditions can make manually querying not work well, but
# I find it's more useful to have no spaces instead.)

unsetopt PROMPT_SP # Disable the default functionality

# Add the function to the list of precommand functions
add-zsh-hook precmd _SampShell-noprint-spaces

# The function in question that handles not printing spaces
function _SampShell-noprint-spaces {
	emulate -L zsh -o ERR_RETURN # Enable `ERR_RETURN` as a convenience
	local line

	print -n '\e[6n'  # Special escape sequence to ask for the current position
	read -s -d R line # Read the current position in
	line=${line#*\;}  # Position is in the format `\e[<LINE>;<COLUMN>`; get the column

	# If we're not at the start of the line, print the EOL mark (or its default)
	(( line != 1 )) && print -P ${PROMPT_EOL_MARK-'%B%S%#%s%b'}
}
