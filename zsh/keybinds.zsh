# This file contains all the keybindings I use

####################################################################################################
#                                      Overwrite ZLE Builtins                                      #
####################################################################################################

## Overwrite some builtins to provide custom behaviour

# Print out the history number when searching for lines in history
function zle-isearch-update { zle -M "Line $HISTNO" }
zle -N zle-isearch-update

# Clear the result from the updated `zsh-isearch-update` when accepting a line
function zle-isearch-exit  { zle -M '' }
zle -N zle-isearch-exit

# Have `clear-screen` instead call our `cls` function
function clear-screen { cls && zle reset-prompt }
zle -N clear-screen

####################################################################################################
#                                               Misc                                               #
####################################################################################################

## Register functions; We use an anonymous function so `fn` doesn't escape
() { local fn; for fn do zle -N $fn; done } ~ss/zsh/widgets/*(:t)

bindkey '^?' kill-region-or-backward-delete-char

## Bind key strokes to do functions
bindkey '^[#'  pound-insert
bindkey '^X^R' redo # like `^X^U` for undo

bindkey '^[/'    SampShell-delete-path-segment
# bindkey '^[h'    SampShell-help

bindkey '^[$' SampShell-make-prompt-simple

## up and down history, but not line-by-line.
bindkey '^[^[[A' up-history
bindkey '^[^[[B' down-history

# Arrow keys that can be used in the future
# bindkey '^[[1;2C' undefined-key # Terminal.app's default sequence for "SHIFT + RIGHT ARROW"
# bindkey '^[[1;2D' undefined-key # Terminal.app's default sequence for "SHIFT + LEFT ARROW"
# bindkey '^[[1;5A' up-history    # (Added as a custom sequence for "CTRL + UP ARROW")
# bindkey '^[[1;5B' down-history  # (Added as a custom sequence for "CTRL + DOWN ARROW")
# bindkey '^[[1;5C' undefined-key # Terminal.app's default sequence for "CTRL + RIGHT ARROW"
# bindkey '^[[1;5D' undefined-key # Terminal.app's default sequence for "CTRL + LEFT ARROW"
# bindkey '^[[H'    undefined-key # TODO: Add into terminal.app as a sequence for `HOME`
# bindkey '^[[E'    undefined-key # TODO: Add into terminal.app as a sequence for `END`


## TODO: HAVE UP ARROW USE `ZLE_LINE_ABORTED``

bindkey '^q' push-line-or-edit

####################################################################################################
#                                Read a character and delete to it                                 #
####################################################################################################

# For some reason `backward-{zap,delete}-to-char` don't exist, so we need to make them ourselves
zmodload zsh/deltochar
function backward-zap-to-char    { zle zap-to-char    -n $(( - ${NUMERIC:-1} )) }
function backward-delete-to-char { zle delete-to-char -n $(( - ${NUMERIC:-1} )) }
zle -N backward-zap-to-char
zle -N backward-delete-to-char
bindkey '^[=' backward-zap-to-char
bindkey '^[+' backward-delete-to-char

####################################################################################################
#                                   Storing and Retrieving Lines                                   #
####################################################################################################

# The builtin `push-line` and `get-line` combo works great, except it always immediately fetches
# the line. This pair of functions here pushes them into an array for later use
typeset -ag _SampShell_stored_lines

bindkey '^[Q' SampShell-store-line
bindkey '^[G' SampShell-retrieve-line
bindkey '^[p' SampShell-add-pbcopy
bindkey '^[c' SampShell-copy-command
bindkey '^[Z' execute-last-named-cmd # it's normally bound to `^[z`
bindkey '^[z' SampShell-put-back-zle


####################################################################################################
#                                             Movement                                             #
####################################################################################################

# ESC + <left/right-arrow> + char = goes to the prev/next instance of `char`
bindkey '^[^[[D' vi-find-prev-char
bindkey '^[^[[C' vi-find-next-char

####################################################################################################
#                               Commands Acting Upon Shell Arguments                               #
####################################################################################################

autoload -Uz select-word-style
zstyle ':zle:SampShell-*-argument' word-style shell

autoload -Uz {backward,forward}-word-match
autoload -Uz {backward-,}kill-word-match
zle -N SampShell-backward-argument backward-word-match
zle -N SampShell-forward-argument forward-word-match
zle -N SampShell-backward-kill-argument backward-kill-word-match
zle -N SampShell-forward-kill-argument kill-word-match

## ESC+ESC does things based on shell words
bindkey '^[^[^[[D'  SampShell-backward-argument
bindkey '^[^[^[[C'  SampShell-forward-argument
bindkey '^[^[^?'    SampShell-backward-kill-argument
bindkey '^[^[^[[3~' SampShell-forward-kill-argument
bindkey '^[^[d'     SampShell-forward-kill-argument

####################################################################################################
#                                         Bracketed Pastes                                         #
####################################################################################################

zle -N bracketed-paste SampShell-bracketed-paste
