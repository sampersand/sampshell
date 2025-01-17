#### Basic SampShell definitions for interactive ZSH shell instances.
# This file shouldn't be sourced directly; instead, the top-level `interactive.sh` file sources it.
#
# The definitions in this file aren't really meant to be changed, as they codify how I use ZSH. Any
# options I'm not certain about go into `interactive/experimental.zsh`, which is `source`d unless
# the `$SampShell_no_experimental` variable is set to a nonempty value.
#
# This file is not the location for functions I normally use, as those change a bit more often.
# those go into `interactive/utils.zsh` instead.
#
# Note that `setopt` is used for setting new options, whereas `unsetopt` is used to set options back
# to their default, in case something else changed them. They're functionally the same, but it's
# easier for me to look at and figure out why i'm doing something one way
#####

autoload -Uz add-zsh-hook

####################################################################################################
#                                                                                                  #
#                                       Changing Directories                                       #
#                                                                                                  #
####################################################################################################

## Add named directories
source ${0:P:h}/named-directories.zsh
[[ -n $SampShell_ROOTDIR  ]] && add-named-dir ss    $SampShell_ROOTDIR
[[ -n $SampShell_TMPDIR   ]] && add-named-dir tmp   $SampShell_TMPDIR
[[ -n $SampShell_TRASHDIR ]] && add-named-dir trash $SampShell_TRASHDIR
[[ -d ~/Desktop           ]] && add-named-dir d     ~/Desktop
[[ -d ~/Downloads         ]] && add-named-dir dl    ~/Downloads

## Default `dirs` to `dirs -v` (which lists line numbers). Passing in any argument disables this.
function dirs { builtin dirs ${@:--v} }

## Setup `cd` options
setopt AUTO_CD           # Enables `dir` to be shorthand for `cd dir` if `dir` isn't a valid command
setopt CDABLE_VARS       # Adds `cd var` as a shorthand for `cd $var` and `cd ~var`.
setopt AUTO_PUSHD        # Have `cd` push directories onto the directory stack like `pushd`
setopt PUSHD_IGNORE_DUPS # Delete old duplicate entries on the directory stack when adding new ones.
setopt CHASE_LINKS       # Ensure symlinks are always resolved when changing directories.

####################################################################################################
#                                                                                                  #
#                                             History                                              #
#                                                                                                  #
####################################################################################################

## Load in history utilities
source ${0:P:h}/history/record-every-command.zsh
source ${0:P:h}/history/history-ignore.zsh
source ${0:P:h}/history/toggle-history.zsh

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
	if [[ ! -t 1 ]]; then
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

####################################################################################################
#                                                                                                  #
#                                               Jobs                                               #
#                                                                                                  #
####################################################################################################
	
## Setup job options (jobs programs in the background, started by eg `echo hi &`)
setopt AUTO_CONTINUE           # Always send `SIGCONT` when disowning jobs, so they run again.
unsetopt NO_MONITOR            # Enable job control, in case it's not already sent
unsetopt NO_CHECK_JOBS         # Confirm before exiting the shell if there's suspended jobs
unsetopt NO_CHECK_RUNNING_JOBS # Same as CHECK_JOBS, but also for running jobs.
unsetopt NO_HUP                # When the shell closes, send SIGHUP to all remaining jobs.

# Same as `jobs -d`, except the directories are on the same line as the jobs themselves
function j { jobs -d $@ | sed -n 'N;s/\n/ /;p'  }

####################################################################################################
#                                                                                                  #
#                                     The Prompt: PS1 and RPS1                                     #
#                                                                                                  #
####################################################################################################

# source ${0:P:h}/prompt/fix-spaces-after-eol-mark-macos.zsh <-- failed experiment

## Options for prompt expansion
setopt PROMPT_SUBST        # Lets you use variables and $(...) in prompts.
setopt TRANSIENT_RPROMPT   # Remove RPS1 when a line is accepted. (Makes it easier to copy stuff.)
unsetopt NO_PROMPT_PERCENT # Ensure `%` escapes in prompts are enabled.
unsetopt NO_PROMPT_BANG    # Don't make `!` mean history number; we do this with %!.
unsetopt NO_PROMPT_{CR,SP} # Ensure a `\r` is printed before a line starts

## Mark `PS1` and `RPS1` as global (so functions can interact with them), but not exported (as then
# other shells would inherit them, and they certainly wouldn't understand the formatting.)
typeset -g +x PS1 RPS1

## Load in the definitions for the `PS1` and `RPS1` variables
source ${0:P:h}/prompt/ps1.zsh
source ${0:P:h}/prompt/rps1.zsh

## Ensure that commands don't have visual effects applied to their outputs. `POSTEDIT` is a special
# variable that's printed after a command's been accepted, but before its execution starts. Here, it
# is set to an escape sequence which resets visual effects.
POSTEDIT=$'\e[m'
# PROMPT_EOL_MARK=$'\e[m'"%B%S%#%s%b" # <--- TODO: is this needed for a reset too?

####################################################################################################
#                                                                                                  #
#                                        Entering Commands                                         #
#                                                                                                  #
####################################################################################################

## Interactive history options
histchars[2]=,            # Change from `^ehco^echo` to `,ehco,echo`; `^` is just so far away lol
setopt HIST_SUBST_PATTERN # The `,pat,repl` shorthand and `:s/` and `:&` modifiers accept patterns
unsetopt NO_BANG_HIST     # Lets you do `!!` and friends on the command line.

## Options that modify valid syntax 
setopt INTERACTIVE_COMMENTS # Enable comments in interactive shells; I use this all the time
setopt RC_QUOTES            # Within `'` strings, `''` is interpreted as an escaped `'`.
setopt MAGIC_EQUAL_SUBST    # Supplying `a=b` on the command line does `~`/`=` expansion
setopt GLOB_STAR_SHORT      # Enable the `**.c` shorthand for `**/*.c`
setopt EXTENDED_GLOB        # Always have extended globs enabled, without needing to set it.
unsetopt NO_EQUALS          # Enables `=foo`, which expands to the full path eg `/bin/foo`
unsetopt NO_SHORT_LOOPS     # Allow short-forms of commands, eg `for x in *; echo $x`

## "Safety" options
setopt NO_CLOBBER       # Technically redundant, should've been set by posix/interactive.sh.
setopt CLOBBER_EMPTY    # With `NO_CLOBBER`, this Lets you clobber empty files
unsetopt RM_STAR_SILENT # In case it's accidentally unset, force `rm *` to ask for confirmation
# note that `CHECK_JOBS` and `CHECK_RUNNING_JOBS` are set in the "Jobs" section.

####################################################################################################
#                                                                                                  #
#                                           Key Bindings                                           #
#                                                                                                  #
####################################################################################################

## Useful keybind aliases
alias bk='noglob bindkey'
alias bkg='bindkey | noglob fgrep -ie'

## Register functions; We use an anonymous function so `fn` doesn't escape
() {
	fpath+=($1)

	local fn
	for fn in $1/*(:t); do
		autoload -Uz $fn
		zle -N $fn
	done
} ${0:P:h}/keybind-functions

## Create a new keymap called `sampshell` based off emacs, then set it as the main one.
bindkey -N sampshell emacs
bindkey -A sampshell main

## Bind key strokes to do functions
bindkey '^[#'    pound-insert
bindkey '^[/'    SampShell-delete-path-segment
bindkey '^[='    SampShell-delete-backto-char
bindkey '^S'     SampShell-strip-whitespace && : # stty -ixon # need `-ixon` to use `^S`
bindkey '^[%'    SampShell-make-prompt-simple
bindkey '^[$'    SampShell-make-prompt-simple
bindkey '^[^[[A' SampShell-up-directory
bindkey '^[c'    SampShell-add-pbcopy
bindkey '^X^R'   redo
bindkey '^XR'    redo
bindkey '^Xr'    redo
alias which-command=which # for `^[?`

bindkey '^[[1;2C' undefined-key # Terminal.app's default sequence for "SHIFT + RIGHT ARROW"
bindkey '^[[1;2D' undefined-key # Terminal.app's default sequence for "SHIFT + LEFT ARROW"
bindkey '^[[1;5A' up-history    # (Added as a custom sequence for "CTRL + UP ARROW")
bindkey '^[[1;5B' down-history  # (Added as a custom sequence for "CTRL + DOWN ARROW")
bindkey '^[[1;5C' undefined-key # Terminal.app's default sequence for "CTRL + RIGHT ARROW"
bindkey '^[[1;5D' undefined-key # Terminal.app's default sequence for "CTRL + LEFT ARROW"

####################################################################################################
#                                                                                                  #
#                                           Autocomplete                                           #
#                                                                                                  #
####################################################################################################
## TODO:
autoload -U compinit; compinit

# ZLE_REMOVE_SUFFIX_CHARS
# ZLE_SPACE_SUFFIX_CHARS
zstyle ':completion:*' use-compctl false # never use old-style completion

if [[ $VENDOR = apple ]]; then
	zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case-insensitive for tab completion
	fignore+=(DS_Store) # boo, DS_Store files!
fi

zmodload -i zsh/complist # May not be required
zstyle ':completion:*' list-colors '' # Add colours to completions
zstyle ':completion:*:*:cd:*' file-sort modification
zstyle ':completion:*:*:rm:*' completer _ignored
zstyle ':completion:*:files' ignored-patterns '(*/|).DS_Store'
# zstyle ':completion:*:files' file-sort '!ignored-patterns '*.DS_Store'

####################################################################################################
#                                                                                                  #
#                                       Experimental Config                                        #
#                                                                                                  #
####################################################################################################

## Load "experimental" options---things I'm not sure yet about.
[[ -z $SampShell_no_experimental ]] && source ${0:P:h}/interactive/experimental.zsh

####################################################################################################
#                                                                                                  #
#                                      Functions and Aliases                                       #
#                                                                                                  #
####################################################################################################

## All helper functions and aliases should be defined here.
source ${0:P:h}/interactive/utils.zsh
