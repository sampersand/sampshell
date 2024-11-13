## This file is used for the "record every command" feature of sampshell.
# I want to do statistical analysis and whatnot on all the commands I've ever run, but I don't want
# to store _all_ those commands within the history (as they're far too easily deleted). As such,
# this file's job is to hook into ZSH's "add history" mechanism, and to output every line that'd be
# stored to ZSH's history _also_ to a separate file.


## Make `zshaddhistory_functions` a unique array, in case it's not already
# This prevents `SampShell-record-every-command` from being recorded twice (eg if we `reload`)
typeset -agU zshaddhistory_functions

## Add the record history function to the end.
# We want it to be the last function, so it'll only record things down if all the previous history
# functions have passed. However, it's not critical for it to be the last one (as this is just used
# for statistical purposes, and nothing mission-critical), so that if functions are added after it,
# it's ok.
zshaddhistory_functions+=SampShell-record-every-command

# Global, non-exported variable, that's hidden from end-users; if set, we won't store history.
typeset +x -gH SampShell_nosave_hist

## Record all commands entered interactively
# This function is called every time the user enters a command on the command line. It saves each
# command that isn't skipped to a file. Note that you can entirely disable this function by setting
# `$SampShell_nosave_hist` to a nonempty value, or by making `$SampShell_HISTDIR` empty.
#
# History functions are always given a single argument, the entire input line, unadulterated (except
# for alias expansion). Their return status indicates what should happen with the line; non-zero
# statuses mean different things (see the docs for more details), but the important part for us is
# that the `0` status means to just "continue on" (ie go to the next history command to see if the
# line should be stored, or if we're the last, then to store it.) We always want to return 0, as we
# don't want errors in this function to prevent lines being stored---this function is an observer.
#
# This function is called for _every_ input line, regardless of what history options are set. While
# we could store every input line, I think it's useful to respect those options---eg, if the option
# `HIST_IGNORE_SPACE` is set (lines starting with a space aren't stored), then we probably don't
# want to store that command---it might have passwords or something in it. So this, along with some
# other options, are checked against.
#
# If we've determined we want to store the command, then the directory at `$SampShell_HISTDIR` is
# made if it doesn't exist already. Then, the file `$SampShell_HISTDIR/<DATE>.sampshell-history` has
# the command appended to it in the format `<time>| <cmd>`, where cmd has all of its leading and
# trailing whitespace stripped, and all remaining newlines are have a tab added after them (to make
# it easier to parse later on)
#
# We rotate the file we store it in each day, so as to not have one massive history file.
SampShell-record-every-command () {
	## Setup
	local -A opts=("${(kv@)options}") # Store options, so we can check for hist options later.
	emulate -L zshEXTENDED_GLOB       # Reset all options (until fn return), then set `EXTENDED_GLOB`

	## Return early if we're not saving history, or there isn't even a place to store history.
	[[ -n $SampShell_nosave_hist || -z $SampShell_HISTDIR ]] && return 0

	## Remove leading/trailing blanks, and then add tabs after all remaining newlines
	local line=$1
	line=${line##[[:space:]]}   # Strip leading whitespace
	line=${line%%[[:space:]]}   # Strip tailing whitespace
	line=${line//$'\n'/$'\n\t'} # Replace all newlines with a newline-tab

	## Check to make sure we actually want to store th elien
	if [[ -z $line ]]; then
		# Ignore blank lines; Since we've stripped whitespace, this includes just whitespace lines too
		return 0
	elif [[ $opts[interactivecomments] = yes && -n $histchars[3] && $line[1] = $histchars[3] ]]; then
		# Ignore a commented line if: (1) The `INTERCATIVE_COMMENTS` option is set (without this, 
		# there's no comments in interactive shells), (2) a "comment char" is even set (ZSH lets you
		# change the comment char from `#`), and (3) the line starts with that character (we stripped
		# whitespace, so we can just check the first character of `$line`.). Note that the history
		# char has to be ASCII, so no need to worry about multibytes.
		return 0
	elif [[ $opts[histignorespace] = yes && $1[1] = ' ' ]]; then
		# If the `HIST_IGNORE_SPACE` option is set, ZSH won't store lines that start with a space. We
		# also won't then. Note that we compare against `$1` and not `$line` here, as `$line` will
		# have had the space stripped.
		return 0
	elif [[ $opts[histnostore] = yes && "$line " = ((history|fc) *) ]]; then
		# If the `HIST_NO_STORE` option is set, then don't record commands which start with `history`
		# or `fc`. (We add the space after the `$line` to make the parsing easier.)
		return 0
	elif [[ -v HISTORY_IGNORE && $line = ${~HISTORY_IGNORE} ]]; then
		# Respect the `$HISTORY_IGNORE`: If it's set, then ignore all lines which match it. (The
		# `$HISTORY_IGNORE` variable can be set to tell ZSH not to write certain patterns to history
		# files.) Note the use of `~`, this tells ZSH to interpret the contents of `$HISTORY_IGNORE`
		# as a pattern, not as those literal characters themselves.
		return 0
	else
		# There's a few options we explicitly don't check for:
		# - `HIST_NO_FUNCTIONS`: I find it useful to record functions regardless
		# - `HIST_IGNORE{,_ALL}_DUPS`: Defeats the point of the function. Hard to do analysis w/o dups
	fi

	## Create the history directory if it doesn't exist.
	if ! mkdir -p $SampShell_HISTDIR; then
		# Uh oh, problem making it! log a warning, and then return.
		SampShell_log "%s: Unable to record command; we couldn't make \$SampShell_HISTDIR: %s" \
			$0 $SampShell_HISTDIR
		return 0 # Return 0 even in failure, so as to not preclude the line being saved in history.
	fi

	## The file we'll be storing the command in. 
	local histfile="$SampShell_HISTDIR/$(date +%F).sampshell-history"

	## Append the line `<datetime>| <cmd>\n` to `$histfile`.
	printf '%s| %s\n' "$(date '+%F %r %z')" $line >> $histfile

	## Everything's successful! Let's return.
	return 0
}
