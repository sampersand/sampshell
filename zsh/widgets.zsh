#!zsh
p unused


## Overwrite the builtin `clear-screen` command by having it call `cls` instead.
function clear-screen {
	cls && zle reset-prompt
}
zle -N clear-screen
bindkey '^[#' pound-insert


## Comment out a line by adding the comment character (default: `#`) and a space
# before the current line, then accepting it.
function pound-insert {
	BUFFER="$histchars[3] $BUFFER"
	zle accept-line
}

function add-pbcopy {
#!zsh

# Add a space unless there's already a space
[[ ${BUFFER: -1} = [[:blank:]] ]] || BUFFER+=' '
BUFFER+='| pbcopy'
zle redisplay

}
