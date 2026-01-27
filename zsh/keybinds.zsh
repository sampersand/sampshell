# This file contains all the keybindings I use

####################################################################################################
#                                               Misc                                               #
####################################################################################################

## Register functions; We use an anonymous function so `fn` doesn't escape
() { local fn; for fn do zle -N $fn; done } ~ss/zsh/widgets/*(:t)

bindkey '^?' kill-region-or-backward-delete-char

## Bind key strokes to do functions
bindkey '^[#'  pound-insert
bindkey '^X^R' redo # like `^X^U` for undo

## up and down history, but not line-by-line.
bindkey '^[^[[A' up-history
bindkey '^[^[[B' down-history

## Read a character, and delete back to it
zmodload zsh/deltochar
bindkey '^[=' SampShell-backward-zap-to-char
bindkey '^[+' SampShell-backward-delete-to-char

####################################################################################################
#                                   Storing and Retrieving Lines                                   #
####################################################################################################

# The builtin `push-line` and `get-line` combo works great, except it always immediately fetches
# the line. This pair of functions here pushes them into an array for later use
typeset -ag _SampShell_stored_lines
bindkey '^[Q' SampShell-store-line
bindkey '^[G' SampShell-retrieve-line

# Other sampshell functions
bindkey '^[p' SampShell-add-pbcopy
bindkey '^[c' SampShell-copy-command
bindkey '^[Z' execute-last-named-cmd # it's normally bound to `^[z`
bindkey '^[z' SampShell-put-back-zle
bindkey '^[/' SampShell-delete-path-segment
bindkey '^[$' SampShell-make-prompt-simple

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
