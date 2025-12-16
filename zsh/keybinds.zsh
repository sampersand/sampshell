## Useful keybind aliases
source ~ss/zsh/movements.zsh

## Register functions; We use an anonymous function so `fn` doesn't escape
() { local fn; for fn do zle -N $fn; done } ~ss/zsh/widgets/*(:t)

bindkey '^?' kill-region-or-backward-delete-char

## Bind key strokes to do functions
bindkey '^[#'    pound-insert
bindkey '^[/'    SampShell-delete-path-segment
bindkey '^S'     SampShell-strip-whitespace && : # stty -ixon # need `-ixon` to use `^S`
bindkey '^[c'    SampShell-add-pbcopy
bindkey '^X^R'   redo
# bindkey '^[h'    SampShell-help

bindkey '^[ c' SampShell-copy-command
bindkey '^[ %' SampShell-make-prompt-simple
bindkey '^[%' SampShell-make-prompt-simple
bindkey '^[$' SampShell-make-prompt-simple
bindkey '^[ $' SampShell-make-prompt-simple
bindkey '^[ z' SampShell-put-back-zle
bindkey '^[ p' SampShell-add-pbcopy


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

bindkey '^q' push-line-or-edit

####################################################################################################
#                                 Read a charcter and delete to it                                 #
####################################################################################################

# For some reason `backward-{zap,delete}-to-char` don't exist, so we need to make them ourselves
zmodload zsh/deltochar
function backward-zap-to-char    { zle zap-to-char    -n $(( - ${NUMERIC:-1} )) }
function backward-delete-to-char { zle delete-to-char -n $(( - ${NUMERIC:-1} )) }
zle -N backward-zap-to-char
zle -N backward-delete-to-charcd
bindkey '^[=' backward-zap-to-char
bindkey '^[+' backward-delete-to-char

####################################################################################################
#                                   Storing and Retrieving Lines                                   #
####################################################################################################

# The builtin `push-line` and `get-line` combo works great, except it always immediately fetches
# the line. This pair of functions here pushes them into an array for later use
typeset -ag _SampShell_stored_lines

# (They're autoloaded, as they're not miniscule)

# Assign them; we overwrite the builtins here, as the upper-case variants are just aliases for lower case
bindkey '^[Q' SampShell-store-line
bindkey '^[G' SampShell-retrieve-line

