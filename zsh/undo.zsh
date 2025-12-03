#!zsh
# This "undoes" options that are normally set, in case something set them in
# /etc/zshrc for some reason...

## Disable options that might've been set
unsetopt HIST_IGNORE_ALL_DUPS # Ensure that non-contiguous duplicates are kept around.
unsetopt HIST_SAVE_NO_DUPS    # (This is just `HIST_IGNORE_ALL_DUPS` but for saving.)
unsetopt NO_APPEND_HISTORY    # Ensure we append to the history file when saving, not overwrite it.
unsetopt SHARE_HISTORY        # Don't constantly share history across interactive shells

unsetopt NO_CHECK_JOBS         # Confirm before exiting the shell if there's suspended jobs
unsetopt NO_CHECK_RUNNING_JOBS # Same as CHECK_JOBS, but also for running jobs.
unsetopt NO_HUP                # When the shell closes, send SIGHUP to all remaining jobs.

unsetopt PROMPT_BANG       # Don't make `!` mean history number; we do this with %!.
unsetopt NO_PROMPT_PERCENT # Ensure `%` escapes in prompts are enabled.
unsetopt NO_PROMPT_{CR,SP} # Ensure a `\r` is printed before a line starts

unsetopt NO_BANG_HIST     # Lets you do `!!` and friends on the command line.

unsetopt NO_EQUALS          # Enables `=foo`, which expands to the full path eg `/bin/foo`
unsetopt NO_SHORT_LOOPS     # Allow short-forms of commands, eg `for x in *; echo $x`

unsetopt RM_STAR_SILENT # In case it's accidentally unset, force `rm *` to ask for confirmation
