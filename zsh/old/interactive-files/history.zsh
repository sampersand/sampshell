#!/bin/zsh

HISTSIZE=1000000     # Keep a lot so it's easy to refernece
SAVEHIST=$HISTSIZE    # how many lines to save at the end

## History options
setopt BANG_HIST            # Who doesn't use `!` for history?
setopt HIST_ALLOW_CLOBBER   # History saves commands as clobber commands
setopt HIST_IGNORE_DUPS # Delete all duplicate commands <--- TODO
setopt NO_HIST_IGNORE_ALL_DUPS # Unset it
echo 'todo:L HIST_IGNORE_ALL_DUPS'
setopt HIST_IGNORE_SPACE    # Don't record lines that start with spaces
setopt NO_HIST_IGNORE_DUPS  # Just to declutter `setopt`
setopt HIST_LEX_WORDS       # We don't store enough for it to matter.
setopt NO_HIST_NO_FUNCTIONS    # Don't put functions in the history, they're a pain.
setopt HIST_NO_STORE        # Don't store `history`/`fc` commands
setopt NO_SHARE_HISTORY     # Dont' sahre history between shell invocations?

## Make `zshaddhistory_functions` a unique array.
typeset -aU zshaddhistory_functions
typeset -gH SampShell_nosave_hist # no need to make it public

## Ensure that `dont-save-disable-history` is before `record-history`, as otherwise we'll be
## recording the disable-history function.
zshaddhistory_functions[1,0]=(SampShell-dont-save-disable-history SampShell-record-history)

## Don't record `disable-history` or `enable-history`
function SampShell-dont-save-disable-history {
	# If the command is disable-history, then don't store that at all.
	[[ ${${1%$'\n'}%%[[:blank:]]} = (disable|enable)-history ]] && return 1
	return 0
}

function {SampShell_,}disable-history {
	fc -p || return $?
	SampShell_nosave_hist=1
	unset SAVEHIST HISTFILE && echo 'History saving disabled.'
}

function {SampShell_,}enable-history {
	SampShell_nosave_hist=
	fc -P && echo 'History saving enabled.'
}

## Record all history commands for posterity

# Records a command in a separate history file.
SampShell-record-history () {
	# print -sr -- ${1%$'\n'}
	emulate -L zsh

	# Note we intentionally always return 0, as any errors in here shouldn't
	# preclude the command from going to main history.

	# IF there's no SampShell_HISTDIR, or we've declared we aren't saving history,
	# then there's nothing to do.
	[[ -z $SampShell_HISTDIR || -n $SampShell_nosave_hist ]] && return 0

	set -- ${1%$'\n'} # Strip the trailing newline

	# Don't save empty lines.
	[[ -z "$1" ]] && return 0

	# Respect different options shell options for ignoring history
	[[ -o HIST_IGNORE_SPACE && ${1[0]} = ' ' ]] && return 0
	[[ -o HIST_NO_STORE     && ($1 = history || $1 = history\ *) ]] && return 0
	[[ -n $HISTORY_IGNORE   && $1 = ${~HISTORY_IGNORE} ]] && return 0

	mkdir -p $SampShell_HISTDIR || return # Create the histdir if it doesn't exist

	# We make the histfile based on the date.
	local histfile="$SampShell_HISTDIR/$(date +%F).history"
	echo "$(date '+%F %r %z')| ${1%%[[:blank:]]}" >>| $histfile
	return 0
}
