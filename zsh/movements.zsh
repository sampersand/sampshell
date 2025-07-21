# --- jump-argument stuff ---
autoload -Uz select-word-style

zstyle ':zle:SampShell-*-argument' word-style shell

autoload -Uz backward-word-match
autoload -Uz forward-word-match
autoload -Uz backward-kill-word-match
autoload -Uz forward-kill-word-match
zle -N SampShell-backward-argument backward-word-match
zle -N SampShell-forward-argument forward-word-match
zle -N SampShell-backward-kill-argument backward-kill-word-match
zle -N SampShell-forward-kill-argument forward-kill-word-match

# zle -N SampShell-forward-argument forward-word-match
bindkey '^[[1;2D' SampShell-backward-argument
bindkey '^[[1;2C' SampShell-forward-argument
bindkey '^[[3;2~' SampShell-forward-kill-argument
bindkey '^[[79;2~' SampShell-backward-kill-argument # `79` is arbitrary code i picked that seems unused
