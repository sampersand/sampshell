# BUFFER='echo hi there frienfriend'
# MARK=14
# CURSOR=20
# BUFFER[MARK,CURSOR]=''
# exit

## TODO: HAVE UP ARROW USE `ZLE_LINE_ABORTED``

bindkey '^Z' undo
bindkey 'Ω' undo # MACOS: OPTION+Z
bindkey '¸' redo # MACOS: OPTION+SHIFT+Z
bindkey '^W' kill-region # delete a higlighted part of a line
bindkey '^[^[[D' vi-find-prev-char
bindkey '^[^[[C' vi-find-next-char
bindkey '^q' push-line-or-edit

source ${0:P:h}/movements.zsh
# ----

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


# bindkey -r '^[ '

# pr () print -zr -- $ZLE_LINE_ABORTED
# bindkey '^[ z' put-back-zle
bindkey '^[ c' SampShell-copy-command
bindkey '^[ p' SampShell-add-pbcopy
bindkey -s '^[ l' '^Qls^M'

# bindkey -N SampShell-git
bindkey -s '^[gaa' '^Qgit add --all^M'
bindkey -s '^[gs'  '^Qgit status^M'


return
  bindkey '\e[[24~' universal-argument

Then if I hit the characters F12, 4, 0, a, a row of forty `a's is inserted onto the command line. I'm not claiming this example is particularly useful.

  *?_-.[]~=/&;!#$%^(){}<>

PREDISPLAY (scalar)

    Text to be displayed before the start of the editable text buffer. This does not have to be a complete line; to display a complete line, a newline must be appended explicitly. The text is reset on each new invocation (but not recursive invocation) of zle.
POSTDISPLAY (scalar)
Text to be displayed after the end of the editable text buffer. This does not have to be a complete line; to display a complete line, a newline must be prepended explicitly. The text is reset on each new invocation (but not recursive invocation) of zle.
