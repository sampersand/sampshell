## All this is experimental

alias bk='noglob bindkey'
alias bkg='bindkey | noglob fgrep -i '

bindkey '^x^z' undo
bindkey '^xz' undo
bindkey Ω undo
bindkey ¥ redo

# bindkey -s '^o' '^Qecho hi^M'
# bindkey -r '^g'
# bindkey -r '^G'
# bindkey -s '^G^s' '^Qgit status^M'
# bindkey -s '^G^S' '^Qgit status^M'
bindkey -s '^Gs' '^Qgit status^M'
bindkey -s '^Gaa' '^Qgit add --all^M'
