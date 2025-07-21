# --- jump-argument stuff ---
autoload -Uz select-word-style

zstyle ':zle:SampShell-*-argument' word-style shell

# `forward-kill` is actually just `kill`
autoload -Uz backward-word-match forward-word-match backward-kill-word-match kill-word-match
zle -N SampShell-backward-argument backward-word-match
zle -N SampShell-forward-argument forward-word-match
zle -N SampShell-backward-kill-argument backward-kill-word-match
zle -N SampShell-forward-kill-argument kill-word-match

bindkey '^[[1;2D' SampShell-backward-argument
bindkey '^[[1;2C' SampShell-forward-argument
bindkey '^[[3;2~' SampShell-forward-kill-argument
bindkey '^[[79;2~' SampShell-backward-kill-argument # `79` is arbitrary code i picked that seems unused
