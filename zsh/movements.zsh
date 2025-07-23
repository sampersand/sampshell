################################################################################
#                                                                              #
#                              SampShell Commands                              #
#                                                                              #
################################################################################

bindkey '^[ c' SampShell-copy-command
bindkey '^[ %' SampShell-make-prompt-simple
bindkey '^[ $' SampShell-make-prompt-simple
bindkey '^[ z' SampShell-put-back-zle
bindkey '^[ p' SampShell-add-pbcopy
# bindkey '^[ t' SampShell-transpose-words


################################################################################
#                                                                              #
#                          Cursor Movement & Deletion                          #
#                                                                              #
################################################################################

autoload -Uz select-word-style
zstyle ':zle:SampShell-*-argument' word-style shell

autoload -Uz backward-word-match
autoload -Uz forward-word-match
autoload -Uz backward-kill-word-match
autoload -Uz transpose-words-match
autoload -Uz kill-word-match # `forward-kill` is actually just `kill`
zle -N SampShell-backward-argument backward-word-match
zle -N SampShell-forward-argument forward-word-match
zle -N SampShell-backward-kill-argument backward-kill-word-match
zle -N SampShell-forward-kill-argument kill-word-match
zle -N SampShell-transpose-argument transpose-words-match

# All of these are shift+<normal value>, as i decided shift is the argument one
bindkey '^[[1;2D' SampShell-backward-argument
bindkey '^[[1;2C' SampShell-forward-argument
bindkey '^[[3;2~' SampShell-forward-kill-argument
bindkey '^[[79;2~' SampShell-backward-kill-argument # `79` is arbitrary code i picked that seems unused
bindkey '^[T' SampShell-transpose-argument

# bindkey 'å'=
# bindkey 'å^[[D' SampShell-backward-argument
# bindkey 'å^[b'  SampShell-backward-argument
# bindkey 'å^[[C' SampShell-forward-argument
# bindkey 'å^[f' SampShell-forward-argument
# bindkey 'å^?' SampShell-backward-kill-argument
# bindkey 'å^[[3~' SampShell-forward-kill-argument
# bindkey 'å^[^?' SampShell-forward-kill-argument


# ESC + <left/right-arrow> + char = goes to the prev/next instance of `char`
bindkey '^[^[[D' vi-find-prev-char
bindkey '^[^[[C' vi-find-next-char
