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
bindkey '^[c'    SampShell-add-pbcopy
bindkey '^X^R'   redo

# "command-space" commands
bindkey '^[ t' SampShell-transpose-words

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

bindkey '^W' kill-region # delete a higlighted part of a line
bindkey '^q' push-line-or-edit

# # Overwrite DELETE to also kill a region if one is present
# backward-delete-char-or-kill-region () {
#   if (( REGION_ACTIVE )) {
#     zle kill-region
#   } else {
#     zle backward-delete-char
#   }
# }
# zle -N backward-delete-char-or-kill-region
# bindkey '^W' backward-delete-char-or-kill-region
