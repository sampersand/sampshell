#!/bin/zsh

SAVEHIST=$HISTSIZE    # how many lines to save at the end

## History options
setopt BANG_HIST          # Who doesn't use `!` for history?
setopt EXTENDED_HISTORY   # more fancy history
setopt HIST_NO_STORE      # Don't store `history` commands
setopt HIST_ALLOW_CLOBBER # History saves commands as clobber commands
setopt HIST_REDUCE_BLANKS # reduce extraneous blanks (sadly not at end of line tho)
setopt HIST_IGNORE_SPACE  # Don't record lines that start with spaces
setopt HIST_FCNTL_LOCK    # We're on a modern operating system, dont use ad-hoc locking mechanisms
setopt HIST_FIND_NO_DUPS  # Don't show dups when searching history
setopt HIST_IGNORE_DUPS   # Only ignore dups if they are dups of the immediately preceding command


## Record all history commands for posterity
typeset -U zshaddhistory_functions
zshaddhistory_functions+=('SampShell_record_history')

# Records a command in a separate history file.
SampShell_record_history () {
	emulate -L zsh

	# Note we intentionally always return 0, as any errors in the commands shouldn't
	# preclude the command from going to main history.

	# IF there's no SampShell_HISTDIR, then there's nothing to do.
	[[ -z $SampShell_HISTDIR ]] && return 0

	set -- ${1%$'\n'} # Strip the trailing newline

	# Respect different options shell options for ignoring history
	[[ -o HIST_IGNORE_SPACE && ${1[0]} = ' ' ]] && return 0
	[[ -o HIST_NO_STORE     && ($1 = history || $1 = history\ *) ]] && return 0
	[[ -n $HISTORY_IGNORE ]] && [[ $1 = ${~HISTORY_IGNORE} ]] && return 0

	# Create the histdir if it doesn't exist
	mkdir -p $SampShell_HISTDIR || return 0

	# We make the histfile based on the date.
	local histfile="$SampShell_HISTDIR/$(date +%F).history"
	echo "$(date '+%F %r %z')| ${1%%[[:blank:]]}" >>| $histfile
	return 0
}

function samp-shell-dont-save-disable-history {
	[[ $1 != disable-history? ]]
}

function disable-history {
	fc -p && unset SAVEHIST HISTFILE && echo 'History saving disabled.'
}

function enable-history {
	fc -P && echo 'History saving enabled.'
}
