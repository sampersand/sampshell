### Add keybindings
alias bk='noglob bindkey'
alias bkg='bindkey | noglob fgrep -ie'

# Creating a new keybinding named `sampshell` based off emacs, then set it as
# the main one.
bindkey -N sampshell emacs
bindkey -A sampshell main

## Delete thinsg that the arrow keys use; Delete is `^H` and could be removed too.
bindkey -r \^{B,F,N,P}

# You can `^F` and `^G` to go forward when searching. I wish there was a `^g`/`^G` though
bindkey '^F' history-incremental-search-forward # we reuse `^S` for strip
bindkey -M isearch '^R' history-incremental-search-backward
bindkey -M isearch '^F' history-incremental-search-forward
bindkey -M isearch '^S' history-incremental-search-forward

####################################################################################################
#                                                                                                  #
#                                        Bindkey Functions                                         #
#                                                                                                  #
####################################################################################################

bindkey '^X^Z' redo
bindkey '^X^Y' undo

bindkey -s '^gs' '^Qgit status^M'
bindkey -s '^gaa' '^Qgit add --all^M'
bindkey -s '^[r' '^Qreload^M'

if [[ -n $Sampshell_experimental ]]; then
	bindkey '^x^z' undo
	bindkey '^xz' undo
	bindkey Ω undo
	bindkey ¥ redo
fi
