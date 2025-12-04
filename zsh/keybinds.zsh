## Useful keybind aliases
source ~ss/zsh/movements.zsh

## Register functions; We use an anonymous function so `fn` doesn't escape
() {
  local fn; for fn do zle -N $fn; done
} ~ss/zsh/widgets/*(:t)

## Create a new keymap called `sampshell` based off emacs, then set it as the main one.
bindkey -N sampshell emacs
bindkey -A sampshell main

## Bind key strokes to do functions
bindkey '^[#'    pound-insert
bindkey '^[='    SampShell-delete-to-char
bindkey '^[+'    SampShell-zap-to-char
bindkey '^[/'    SampShell-delete-path-segment
bindkey '^S'     SampShell-strip-whitespace && : # stty -ixon # need `-ixon` to use `^S`
bindkey '^[^[[A' SampShell-up-directory
bindkey '^[c'    SampShell-add-pbcopy
bindkey '^X^R'   redo
bindkey '^XR'    redo
bindkey '^Xr'    redo

# "command-space" commands
bindkey '^[ t' SampShell-transpose-words
bindkey -s '^[ l' '^Qls^M'

## up and down history, but without going line-by-line
bindkey '^P' up-history
bindkey '^N' down-history

# Arrow keys that can be used in the future
bindkey '^[[1;2C' undefined-key # Terminal.app's default sequence for "SHIFT + RIGHT ARROW"
bindkey '^[[1;2D' undefined-key # Terminal.app's default sequence for "SHIFT + LEFT ARROW"
bindkey '^[[1;5A' up-history    # (Added as a custom sequence for "CTRL + UP ARROW")
bindkey '^[[1;5B' down-history  # (Added as a custom sequence for "CTRL + DOWN ARROW")
bindkey '^[[1;5C' undefined-key # Terminal.app's default sequence for "CTRL + RIGHT ARROW"
bindkey '^[[1;5D' undefined-key # Terminal.app's default sequence for "CTRL + LEFT ARROW"
bindkey '^[[H'    undefined-key # TODO: Add into terminal.app as a sequence for `HOME`
bindkey '^[[E'    undefined-key # TODO: Add into terminal.app as a sequence for `END`


## TODO: HAVE UP ARROW USE `ZLE_LINE_ABORTED``

bindkey '^Z' undo
bindkey 'Ω' undo # MACOS: OPTION+Z
bindkey '¸' redo # MACOS: OPTION+SHIFT+Z
bindkey '^W' kill-region # delete a higlighted part of a line
bindkey '^q' push-line-or-edit

# ----

# bindkey -r '^[ '

# pr () print -zr -- $ZLE_LINE_ABORTED
# bindkey '^[ z' put-back-zle
bindkey -s '^[ l' '^Qls^M'

# bindkey -N SampShell-git
bindkey -s '^[gaa' '^Qgit add --all^M'
bindkey -s '^[gs'  '^Qgit status^M'


# return
#   bindkey '\e[[24~' universal-argument

# Then if I hit the characters F12, 4, 0, a, a row of forty `a's is inserted onto the command line. I'm not claiming this example is particularly useful.

#   *?_-.[]~=/&;!#$%^(){}<>

# PREDISPLAY (scalar)

#     Text to be displayed before the start of the editable text buffer. This does not have to be a complete line; to display a complete line, a newline must be appended explicitly. The text is reset on each new invocation (but not recursive invocation) of zle.
# POSTDISPLAY (scalar)
# Text to be displayed after the end of the editable text buffer. This does not have to be a complete line; to display a complete line, a newline must be prepended explicitly. The text is reset on each new invocation (but not recursive invocation) of zle.

