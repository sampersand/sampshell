## Functions for enabling and disabling history recording.
# History in ZSH is written periodically, when manually requested (via `fc -W`), or when the shell
# exits, to the `$HISTFILE` parameter (with `$SAVEHIST` entries being written). To "disable" ZSH's
# history mechanism, one simply has to unset these variables, and ZSH won't have anywhere to store
# the history.
#
# ZSH provides a nice little builtin pair to "push" (`fc -p`) and "pop" (`fc -P`) these two
# variables onto a stack. So, `history-disable` "pushes" the current $HISTFILE and $SAVEHIST vars
# onto the stack (via `fc -p`), but doesn't set new ones. This means ZSH has nowhere to save the
# history. When `history-enable` is later executed, assuming they haven't been manually set after
# the `history-disable`, the `fc -P` will attempt to write the current history to an empty file, and
# thus just discards it.
#
# At the bottom of the file, `SampShell-history-ignore-command` is called to make sure none of these
# commands are stored in the history.
##

## Global, non-exported variable, whose value is hidden from end-users; its primary purpose is
# actually within `record-every-command.zsh`, as it uses it to determine whether commands should be
# recorded or not. It's also used within `history-{enable,disable,toggle}`.
#
# This variable is also `typeset` within `record-every-command.zsh`.
typeset +x -gH _SampShell_history_disabled

## Disables history
function {SampShell-,}history-disable {
	emulate -L zsh # Reset the shell to the default ZSH options

	# If any options are given, that's an error.
	if (( $# != 0 )) then
		print >&2 "usage: $0"
		print >&2
		print >&2 'Disables the saving of history to files'
		return 1
	fi

	# If history is already disabled, that's an error.
	if (( _SampShell_history_disabled )) then
		print >&2 'History saving already disabled.'
		return 2
	fi

	# Push `$HISTFILE` and `$SAVEHIST` onto a stack, unset them. Then set
	# `_SampShell_history_disabled` to 1, and print a message.
	fc -p && _SampShell_history_disabled=1 && print 'History saving disabled.'
}

## Enables recording history again. Any commands that were entered since the `disable-history` was
# run are discarded (assuming HISTFILE/SAVEHIST weren't updated).
function {SampShell-,}history-enable {
	emulate -L zsh # Reset the shell to the default ZSH options

	# If any options are given, that's an error.
	if (( $# != 0 )) then
		print >&2 "usage: $0"
		print >&2
		print >&2 'Enables the saving of history to files.'
		return 1
	fi

	# If history is already enabled, that's an error.
	if (( ! _SampShell_history_disabled )) then
		print >&2 'History saving already enabled.'
		return 2
	fi

	# Save the history to `$HISTFILE` and `$SAVEHIST` (if they were set; they won't be after a
	# `disable-history` unless something manually touched them), then pop those variables from
	# their stack. Then set unset `_SampShell_history_disabled`, and print a message.
	fc -P && _SampShell_history_disabled= && print 'History saving enabled.'
}

## Either disables or enables history, depending on the `_SampShell_history_disabled` variable.
function history-toggle {
	emulate -L zsh # Reset the shell to the default ZSH options

	# If any options are given, that's an error.
	if (( $# != 0 )) then
		print >&2 "usage: $0"
		print >&2
		print >&2 'Toggles whether history is currently active.'
		return 1
	fi

	# Enable or disable based on the variable
	if (( _SampShell_history_disabled )) then
		enable-history
	else
		disable-history
	fi
}

## Ensure we don't save the commands variants
SampShell-history-ignore-command history-{enable,disable,toggle}
