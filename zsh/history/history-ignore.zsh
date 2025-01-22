## Disable history for specific commands.
# (NOTE: Since this command affects the shell itself, it must be `.` or `source`d to work properly.)
#
# This file adds in a new hook to ZSH's history mechanism to ensure that any commands passed to the
# exposed `history-ignore-command` function aren't actually recorded in the history. For example:
#
#	# Ignore all `ls` commands
#	history-ignore-command ls
#
#	# Ignore `echo`, `cat`, and `cd`
#	history-ignore-command echo cat cd
#
#	# Ignore commands which start with `git status`. This uses ZSH's parsing so
#	# entering `git<TAB><SPACE>status` would still match this.
#	history-ignore-command 'git status'
#
# Note that ZSH will always keep the previous command around in case you need to edit it, regardless
# of any settings. You can just do an `ls` or something after entering one of these ignored commands
# to ensure that even after pressing "up arrow" it won't exist.
#
# ## SEE ALSO:
# There's a few builtins options ZSH has which you can tweak instead of using this:
# - `setopt HIST_IGNORE_SPACE` - If set, commands that start with a space are ignored
# - `setopt HIST_NO_FUNCTIONS` - If set, commands that declare functions are ignored
# - `setopt HIST_NO_STORE`     - If set, `history` and `fc -l` commands aren't stored
#
# Additionally, there's a variable `HISTORY_IGNORE`, which can be set to a pattern of commands to
# ignore. However, it only works when _writing_ commands to a file, not immediately, which is why
# this file exists.
##

## The list of commands to ignore. This variable isn't meant to be directly interacted with.
# - `-g +x`: Globally visible within this shell, but not exported to other programs.
# - `-aU`  : Declares it as an array that ensures its arguments are always unique.
# - `-H`   : Hide its values when `typeset`ing, as it's "private"
typeset -g +x -aU -H _SampShell_history_ignore_commands

## The hook function.
# If the function returns `1`, that indicates to ZSH that the command shouldn't be stored, and none
# of the remaining hook functions are run. If it returns `0`, ZSH will continue executing other
# hook functions.
#
# ZSH always passes in a single argument to history hook functions, the raw input line, unedited.
function _SampShell-history-ignore-commands-hook {
	# Reset ZSH to default options for just this function, so we don't get affected by
	# user-specific config.
	emulate -L zsh

	# Local variables used in the function
	local command ignore_prefix split_prefix want given

	# Split the command into its arguments, using ZSH-style syntax parsing (eg remove comments,
	# squash consecutive whitespace, etc.). This is done so we can match command prefixes.
	command=( ${(Z+Cn+)1} )

	# Iterate over the list of ignored command prefixes, so we can see if they match.
	for ignore_prefix in $_SampShell_history_ignore_commands; do
		# Split apart the ignored prefix using ZSH-style parsing (but do keep comments, in
		# case the command includes a `#`),
		split_prefix=( ${(z)ignore_prefix} )

		# If the split prefix has more arguments than the command itself, it cannot possibly
		# match. So, we `continue` so we don't fall through
		((  $#split_prefix > $#command )) && continue

		# zip $split_prefix and $command together, stopping when $split_prefix is exhausted.
		for want given in ${split_prefix:^command}; do
			# If what we want isn't equal to what we were given, the prefix doesn't
			# match. Continue the outer for loop.
			[[ $want != $given ]] && continue 2
		done

		# The prefix matched, so we shouldn't record it. Return `1` to indicate this.
		return 1

	done

	# None of the prefixes matched, so return `0` to indicate we don't care if it's stored.
	return 0
}

## Make sure our hook is the very first hook that's run.
# While it's not a strict requirement that it's run before all the other hooks (if any hook returns
# a non-zero return status, the rest of them aren't run), it's first so that other hooks don't see
# a line which is ultimately not going to be recorded.
zshaddhistory_functions=( _SampShell-history-ignore-commands-hook $zshaddhistory_functions )

## Add commands to the list of commands to ignore.
function {SampShell-,}history-ignore-command {
	emulate -L zsh # Reset ZSH to default options for this function

	# If no arguments are given, print an error message and return.
	if (( $# == 0 )) then
		print >&2 "usage: $0 command [...commands]"
		print >&2
		print >&2 "Don't save invocations of 'command' in history. The commands can include"
		print >&2 "spaces in them, and will match subcommands (eg if command='git status',"
		print >&2 "then it'll match 'git status', but not 'git commit'; these subcommands"
		print >&2 "use ZSH's word splitting so no need to worry about using spaces)"
		return 1
	fi

	# Add the arguments to `_SampShell_history_ignore_commands`.
	_SampShell_history_ignore_commands+=($@)
}


