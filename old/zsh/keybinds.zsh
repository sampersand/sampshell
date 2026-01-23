# I don't need to transpose words really
autoload -Uz transpose-words-match
zle -N SampShell-transpose-argument transpose-words-match
bindkey '^[T' SampShell-transpose-argument


## Subsumed by me just learning `^W`
# backwards-delete-char-or-region () {
# 	if (( MARK != 0 )) {
# 		if (( CURSOR < MARK )) {
# 			BUFFER[CURSOR,MARK]=''
# 		} else  {
# 			BUFFER[MARK,CURSOR]=''
# 		}
# 		MARK=
# 		zle redisplay
# 	} else {
# 		zle backward-delete-char
# 	}
# }
# zle -N backwards-delete-char-or-region
# bindkey '^H' backwards-delete-char-or-region
# bindkey '^?' backwards-delete-char-or-region

bindkey '^Z' undo
bindkey 'Ω' undo # MACOS: OPTION+Z
bindkey '¸' redo # MACOS: OPTION+SHIFT+Z
bindkey '^XR'    redo
bindkey '^Xr'    redo
bindkey -s '^[ l' '^Qls^M'


# bindkey -r '^[ '

# pr () print -zr -- $ZLE_LINE_ABORTED
# bindkey '^[ z' put-back-zle
bindkey -s '^[ l' '^Qls^M'

# bindkey -N SampShell-git
bindkey -s '^[gaa' '^Qgit add --all^M'
bindkey -s '^[gs'  '^Qgit status^M'
bindkey '^[^[[A' SampShell-up-directory

# "command-space" commands
bindkey '^[ t' SampShell-transpose-words # never ended up using this

##### No need to do this really, nothing else mucks with keybinds:
## Create a new keymap called `sampshell` based off emacs, then set it as the main one.
bindkey -N sampshell emacs
bindkey -A sampshell main

bindkey '^S'     SampShell-strip-whitespace && : # stty -ixon # need `-ixon` to use `^S`

# return
#   bindkey '\e[[24~' universal-argument

# Then if I hit the characters F12, 4, 0, a, a row of forty `a's is inserted onto the command line. I'm not claiming this example is particularly useful.

#   *?_-.[]~=/&;!#$%^(){}<>

# ----

# PREDISPLAY (scalar)

#     Text to be displayed before the start of the editable text buffer. This does not have to be a complete line; to display a complete line, a newline must be appended explicitly. The text is reset on each new invocation (but not recursive invocation) of zle.
# POSTDISPLAY (scalar)
# Text to be displayed after the end of the editable text buffer. This does not have to be a complete line; to display a complete line, a newline must be prepended explicitly. The text is reset on each new invocation (but not recursive invocation) of zle.



# function zle_line_aborted-or-up-line-or-history {
#   typeset -g __line_aborted_drawn
#   if (( $+ZLE_LINE_ABORTED )) {
#     LBUFFER+=$ZLE_LINE_ABORTED
#     zle redisplay
#   } else {
#     zle up-line-or-history
#   }
# }
# zle -N zle_line_aborted-or-up-line-or-history
# bindkey '^[[A' zle_line_aborted-or-up-line-or-history



# bindkey 'å'=
# bindkey 'å^[[D' SampShell-backward-argument
# bindkey 'å^[b'  SampShell-backward-argument
# bindkey 'å^[[C' SampShell-forward-argument
# bindkey 'å^[f' SampShell-forward-argument
# bindkey 'å^?' SampShell-backward-kill-argument
# bindkey 'å^[[3~' SampShell-forward-kill-argument
# bindkey 'å^[^?' SampShell-forward-kill-argument
	
