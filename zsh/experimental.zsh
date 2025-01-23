## Options I'm not sure if I want to set or not.
[[ -n $ENV ]] && emulate sh -c '. "${(e)ENV}"'

: "${a=4}" # Print the duration of commands that take more than 4s of CPU time
# DIRSTACKSIZE=30   # I just started using dirstack more, if it ever grows unwieldy I can set this.

setopt EXTENDED_HISTORY     # (For fun) When writing cmds, write their start time & duration too.
setopt COMPLETE_IN_WORD
setopt CORRECT              # Correct commands when executing.
setopt RM_STAR_WAIT         # Wait 10 seconds before accepting the `y` in `rm *`
setopt CASE_GLOB CASE_PATHS # Enable case-insensitive globbing, woah!
setopt NO_FLOW_CONTROL      # Modern terminals dont need control flow lol
# WORDCHARS=$WORDCHARS # ooo, you can modify which chars are for a word in ZLE
CORRECT_IGNORE='_*' # Don't correct to functions starting with `_`
# CORRECT_IGNORE_FILE ; setopt correct_all

## Defaults that probably shoudl eb set
unsetopt IGNORE_EOF      # In case it was set, as I use `ctrl+d` to exit a lot.
unsetopt GLOB_SUBST SH_GLOB # defaults that should be set

## 
TMPPREFIX=$TMPDIR/.zsh # todo; shoudl this be set to SampShell_TMPDIR?
mkdir -p $TMPPREFIX

####################################################################################################
#                                                                                                  #
#                                        Failed Experiments                                        #
#                                                                                                  #
####################################################################################################

return

setopt CSH_JUNKIE_LOOPS # Allow loops to end in `end`; only loops tho not ifs. also doesnt let short-formofthings
KEYBOARD_HACK=\' # ignore an odd-number of `'`s, but also on line continuation, ugh.

PROMPT_EOL_MARK=$'\e[m'"%B%S%#%s%b" # <--- TODO: is this needed for a reset too?

# HISTFILE=...     # HISTFILE is already setup within `posix/interactive.sh`.
# HISTORY_IGNORE='(cmd1|cmd2*)' # If set, don't write lines that match to the HISTFILE when saving.

## File called `fix-spaces-after-eol-mark-macos.zsh:
	####################################################################################################
	# (This is a failed experiment, because it will swallow characters that're typed before the prompt #
	# is written. If there's a way to get the current cursor position _without_ reading from stdin, or #
	# if you could somehow "put back" characters this might be doable?)                                #
	####################################################################################################

	# ZSH by default helpfully prints out an inverted `%` when an incomplete line is printed. However,
	# it ends up adding _lots_ of spaces to stdout, which makes it annoying to copy on Terminal in
	# MacOS. (This is usually correct, as race conditions can make manually querying not work well, but
	# I find it's more useful to have no spaces instead.)

	unsetopt PROMPT_SP # Disable the default functionality

	# Add the function to the list of precommand functions
	add-zsh-hook precmd _SampShell-noprint-spaces

	# The function in question that handles not printing spaces
	function _SampShell-noprint-spaces {
		emulate -L zsh -o ERR_RETURN # Enable `ERR_RETURN` as a convenience
		local line

		print -n '\e[6n'  # Special escape sequence to ask for the current position
		read -s -d R line # Read the current position in
		line=${line#*\;}  # Position is in the format `\e[<LINE>;<COLUMN>`; get the column

		# If we're not at the start of the line, print the EOL mark (or its default)
		(( line != 1 )) && print -P ${PROMPT_EOL_MARK-'%B%S%#%s%b'}
	}
## END THAT FILE
