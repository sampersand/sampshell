## Disable recording history. This does the following:
# 1. Pushes the current $HISTFILE and $SAVEHIST vars onto a stack (so that a later `enable-history`
#    can resume where we left off)
# 2. Clears $HISTFILE and $SAVEHIST, so that if the shell is exited nothing is saved
# 3. Sets `_SampShell_dont_record_every_command`, so that the "record-every-command" won't record any commands.
##
function disable-history {
	if [[ -n $_SampShell_dont_record_every_command ]] then
		print 'History saving already disabled' >&2
		return 1
	fi

	fc -p && _SampShell_dont_record_every_command=1 && print 'History saving disabled.'
}

## Enables recording history again. Any commands that were entered since the `disable-history` was
# run are discarded (assuming HISTFILE/SAVEHIST weren't updated).
function enable-history {
	if [[ -z $_SampShell_dont_record_every_command ]] then
		print 'History saving already enabled' >&2
		return 1
	fi

	fc -P && _SampShell_dont_record_every_command= && print 'History saving enabled.'
}

## Either disables or enables history, depending on the `
function toggle-history {
	if [[ -n $_SampShell_dont_record_every_command ]] then
		enable-history
	else
		disable-history
	fi
}

## Ensure we don't save the commands variants
SampShell-history-ignore-command {enable,disable,toggle}-history
