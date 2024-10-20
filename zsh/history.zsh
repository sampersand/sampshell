#!/bin/zsh

## History options
setopt EXTENDED_HISTORY   # more fancy history
setopt HIST_ALLOW_CLOBBER # History saves commands as clobber commands
setopt HIST_REDUCE_BLANKS # reduce extraneous blanks (sadly not at end of line tho)
setopt HIST_IGNORE_SPACE  # Don't record lines that start with spaces
# setopt HIST_NO_STORE    # <-- doesn't actually work with `h` or `history`; and i dont use fc
setopt HIST_FCNTL_LOCK    # We're on a modern operating system, dont use ad-hoc locking mechanisms
setopt HIST_FIND_NO_DUPS  # Don't show dups when searching history
setopt HIST_IGNORE_DUPS   # Only ignore dups if they are dups of the immediately preceding command

## Set defaults for history, and add an alias
function history () {
	builtin history -i ${@:--20}
}

## Enable/Disable history. 
typeset -U zshaddhistory_functions
zshaddhistory_functions+=('samp-shell-dont-save-disable-history')
function samp-shell-dont-save-disable-history {
	[[ $1 != disable-history? ]]
}

function disable-history {
	fc -p && unset SAVEHIST HISTFILE && echo 'History saving disabled.'
}

function enable-history {
	fc -P && echo 'History saving enabled.'
}

## Predefined functions to ignore
zshaddhistory_functions+=('samp-shell-ignore-history-bultins')
function samp-shell-ignore-history-bultins {
	[[ ${1[(w)1]} != h(|istory) ]]
}
