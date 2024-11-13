## This file is used for the "record every command" feature of sampshell.
# I want to do statistical analysis and whatnot on all the commands I've ever run, but I don't want
# to store _all_ those commands within the history (as they're far too easily deleted). As such,
# this file's job is to hook into ZSH's "add history" mechanism, and to output every line that'd be
# stored to ZSH's history _also_ to a separate file.


## Make `zshaddhistory_functions` a unique array, in case it's not alread
typeset -agU zshaddhistory_functions

# Global, non-exported variable, that's hidden from end-users; if set, we won't store history.
typeset +x -gH SampShell_nosave_hist

## Ensure that `dont-save-disable-history` is before `record-history`, as otherwise we'll be
## recording the disable-history function.
zshaddhistory_functions[1,0]=(SampShell-record-history)

## Record all history commands for posterity

# Records a command in a separate history file.
# Note we intentionally always return 0, as any errors in here shouldn't
# preclude the command from going to main history.
SampShell-record-history () {
	# Disable xtrace/verbose if they were enabled, and then set our own options; Note we can't use
	# an `emulate zsh`, as we will be testing against history options later on.
	setopt LOCAL_OPTIONS NO_{XTRACE,VERBOSE} EXTENDED_GLOB NO_UNSET

	# Return early if we're not saving history, or there isn't even a place to store history.
	[[ -n $SampShell_nosave_hist || -z $SampShell_HISTDIR ]] && return 0

	# Strip whitespace
	local line=${${1##[[:blank:]]}%%[[:blank:]]}

	# Check for lines which we don't want to store. We don't store empty lines/just commented lines,
	# as well as we respect the HIST_IGNORE_SPACE and HIST_NO_STORE options and the HISTORY_IGNORE
	# variable. Notably we don't respect the HIST_NO_FUNCTIONS option 'cause I think it's useful to
	# see what functions I've defined over time. (Also, it's kinda annoying to test for them).
	[[
		(-z $line) || # Ignore blank lines
	 	(-n "${histchars[3]:-}" && $line = ${histchars[3]}*) || # ignore comments
	 	(-v HISTORY_IGNORE    && $line = ${~HISTORY_IGNORE}) || # respect HISTORY_IGNORE
	 	(-o HIST_IGNORE_SPACE && ${1[1]} == ' ') || # ignore spaces leading spaces; note this uses `$1`
	 	(-o HIST_NO_STORE     && "$line " = (history *|fc *)) # dont store history commands
	]] && return 0

	# Try to make the history directory if it doesn't already exist; if there's a problem, then log
	# a verbose warning and just exit.
	if ! mkdir -p $SampShell_HISTDIR; then
		SampShell_log '%s: Unable to record history, as there was a problem making the histdir: %s' \
			$0 $SampShell_HISTDIR
	fi

	# Print out the line, along with the current date/time, to the history file; note that this file
	# changes each day, so as to not have one massive history file.
	printf '%s| %s\n' "$(date '+%F %r %z')" $line >>! "$SampShell_HISTDIR/$(date +%F).sampshell-history"

	# Success!
	return 0
}
