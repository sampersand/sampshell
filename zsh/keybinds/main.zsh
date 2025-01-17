### Add keybindings
alias bk='noglob bindkey'
alias bkg='bindkey | noglob fgrep -ie'

####################################################################################################
#                                  Register all keybind functions                                  #
####################################################################################################

() { # Use an anonymous function so `fn` doesn't escape
	local fn

	fpath+=($1)

	for fn in $1/*(:t); do
		autoload -Uz $fn
		zle -N $fn
	done
} ${0:A:h}/functions


####################################################################################################
#                                        Register Keybinds                                         #
####################################################################################################

## Create a new keymap called `sampshell` based off emacs, then set it as the main one.
bindkey -N sampshell emacs
bindkey -A sampshell main

## Bind key strokes to do functions
bindkey '^[#' pound-insert
bindkey '^[/' SampShell-delete-path-segment
bindkey '^[=' SampShell-delete-backto-char
bindkey '^S'  SampShell-strip-whitespace && : # stty -ixon # need `-ixon` to use `^S`
bindkey '^[%' SampShell-make-prompt-simple
bindkey '^[$' SampShell-make-prompt-simple

bindkey '^[^[[A' SampShell-up-directory
bindkey '^[c' SampShell-add-pbcopy
bindkey '^X^R' redo
bindkey '^XR' redo
bindkey '^Xr' redo
alias which-command=which

# bindkey '^[[1;2C' <-- Terminal.app's default sequence for "SHIFT + RIGHT ARROW"
# bindkey '^[[1;5C' <-- Terminal.app's default sequence for "CTRL + RIGHT ARROW"
# bindkey '^[[1;2D' <-- Terminal.app's default sequence for "SHIFT + LEFT ARROW"
# bindkey '^[[1;5D' <-- Terminal.app's default sequence for "CTRL + LEFT ARROW"
