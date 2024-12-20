source ${0:P:h}/record-every-command.zsh
source ${0:P:h}/history-ignore.zsh
source ${0:P:h}/toggle-history.zsh

## Setup history parameters
HISTSIZE=1000000   # Maximum number of history events. It's large so we can use ancient commands
SAVEHIST=$HISTSIZE # How many events to write when saving; Set to HISTSIZE to ensure we save 'em all
# HISTFILE=...     # HISTFILE is already setup within `posix/interactive.sh`.
# HISTORY_IGNORE='(cmd1|cmd2*)' # If set, don't write lines that match to the HISTFILE when saving.

## Setup history options
setopt HIST_FCNTL_LOCK        # Use `fcntl` to lock files. (Supported by all modern computers.)
setopt HIST_REDUCE_BLANKS     # Remove extra whitespace between arguments.
setopt HIST_ALLOW_CLOBBER     # Add `|` to `>` and `>>`, so that re-running the command can clobber.
setopt HIST_NO_STORE          # Don't store the `history` command, or `fc -l`.
setopt HIST_IGNORE_SPACE      # Don't store commands that start with a space.
setopt HIST_IGNORE_DUPS       # Don't store commands that're identical to the one before.
setopt HIST_EXPIRE_DUPS_FIRST # When trimming, delete duplicates commands first, then uniques.

## Disable options that might've been set
unsetopt HIST_IGNORE_ALL_DUPS # Ensure that non-contiguous duplicates are kept around.
unsetopt HIST_SAVE_NO_DUPS    # (This is just `HIST_IGNORE_ALL_DUPS` but for saving.)
unsetopt NO_APPEND_HISTORY    # Ensure we append to the history file when saving, not overwrite it.
unsetopt SHARE_HISTORY        # Don't constantly share history across interactive shells

## Same as `history` except it also numbers its output lines
function h {
	# If we're not connected to a TTY, the just act like `history`, except all values are
	# printed out by default. This lets us do `h | grep ...`
	if [ ! -t 1 ]; then
		history ${@:-0}
		return
	fi

	local sep amount

	# Number the output lines
	history $@ | while read -r; do
		amount=-$(( HISTCMD - ${REPLY[(wr)<->]} ))
		printf "%${sep:=$#amount}d %s\\n" $amount $REPLY
	done
}

history-ignore-command h
