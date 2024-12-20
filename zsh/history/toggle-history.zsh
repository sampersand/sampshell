## Disable recording history. This does the following:
# 1. Pushes the current $HISTFILE and $SAVEHIST vars onto a stack (so that a later `enable-history`
#    can resume where we left off)
# 2. Clears $HISTFILE and $SAVEHIST, so that if the shell is exited nothing is saved
# 3. Sets `_SampShell_nosave_hist`, so that the "record-every-command" won't record any commands.
##
function {SampShell-,}disable-history {
	fc -p || return

	if (( _SampShell_nosave_hist++ )) then
		print '[INFO] History saving already disabled.'
	else
		print 'History saving disabled.'
	fi
}

## Enables recording history again. Any commands that were entered since the `disable-history` was
# run are
function {SampShell-,}enable-history {
	fc -P || return

	if (( --_SampShell_nosave_hist )) then
		print '[INFO] History saving already enabled.'
	else
		print 'History saving enabled.'
	fi
}


function {SampShell-,}toggle-history () {
	if [[ -n $_SampShell_nosave_hist ]] then
		SampShell-enable-history
	else
		SampShell-disable-history
	fi
}

## Ensure we don't save the commands variants
history-ignore-command SampShell-{enable,disable}-history
