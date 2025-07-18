#### Basic SampShell definitions for interactive ZSH shell instances.
# This file shouldn't be sourced directly; instead, the top-level `.posix_rc` file sources it.
#
# The definitions in this file aren't really meant to be changed, as they codify how I use ZSH. Any
# options I'm not certain about go into `experimental.zsh`, which is `source`d unless the variable
# `$SampShell_no_experimental` is set to a nonempty value.
#
# This file is not the location for functions, but rather configuration; Functions go into the
# `utils.zsh` or `functions.zsh` files instead.
#
# Note that `setopt` is used for setting options to a value other than their default, whereas I use
# `unsetopt` to set options back to their default in case something changed them. While not required
# (`setopt no_...` is the same as `unsetopt ...`), I find it easier to reason about this way.
#
# Note: This file intentionally doesn't start with a `.`, as it's not meant to be used directly as
# a user's `.zshrc`. (Instead, `source` the top-level `.posix_rc` file if needed.)
#####

# If SampShell_DISABLED is set to a non-empty value, then don't do any setup
[[ -n $SampShell_DISABLED ]] && return

# Load universal sampshell config; `SampShell_ROOTDIR` should already have been set.
emulate sh -c '. "${SampShell_ROOTDIR:?}/.posix_rc"'

####################################################################################################
#                                           Setup $PATH                                            #
####################################################################################################

typeset -xgU path  # Ensure `path` is unique, and export it (in case it wasn't already).

####################################################################################################
#                                                                                                  #
#                                   Add in autoloaded functions                                    #
#                                                                                                  #
####################################################################################################

## Mark all the functions within the `functions` directory as autoloaded functions: They'll only be
# loaded when they're first executed. (The `-U` flag specifies no aliases are used when expanding
# the functions, `-z` specifies they're autoloaded in ZSH-style, not KSH. Since we use absolute
# paths, they won't use the normal `$fpath` expansion.)
autoload -Uz $SampShell_ROOTDIR/zsh/functions/*

####################################################################################################
#                                                                                                  #
#                                           Directories                                            #
#                                                                                                  #
####################################################################################################

## Add named directories
function add-named-dir {
	emulate -L zsh

	if (( ! $# )) then
		print >&2 -r "usage: $0 [name=]dir [[name=]dir ...]"
		print >&2 "adds 'dir' to the list of named directories; if no name is"
		print >&2 "given, it defaults to the base of 'dir'."
		return 1
	fi

	local MATCH MBEGIN MEND
	hash -d -- ${(*)@/#%(#m)^[[:alnum:]_-]#=*/${MATCH:t}=$MATCH}
}

[[ -n $SampShell_ROOTDIR  ]] && add-named-dir ss=$SampShell_ROOTDIR
[[ -n $SampShell_TRASHDIR ]] && add-named-dir trash=$SampShell_TRASHDIR
[[ -d ~/tmp               ]] && add-named-dir tmp=$HOME/tmp   # (Have to use `$HOME` because...
[[ -d ~/Desktop           ]] && add-named-dir d=$HOME/Desktop # `MAGIC_EQUAL_SUBST` isn't set yet)
[[ -d ~/Downloads         ]] && add-named-dir dl=$HOME/Downloads

## Have `d` act like `dirs`, except it also lists line numbers; Passing any args disables this.
function d {
	emulate -L zsh
	builtin dirs ${@:--v}
}

## Setup `cd` options
setopt CDABLE_VARS  # Adds `cd var` as a shorthand for `cd $var` and `cd ~var`.
setopt AUTO_PUSHD   # Have `cd` push directories onto the directory stack like `pushd`
setopt CHASE_LINKS  # Ensure symlinks are always resolved when changing directories.

####################################################################################################
#                                                                                                  #
#                                             History                                              #
#                                                                                                  #
####################################################################################################

## Load in the "record every command" functionality, unless it's been explicitly opted out of
if zstyle -T ':sampshell:history:record-every-command' enabled; then
	source $SampShell_ROOTDIR/zsh/record-every-command.zsh
fi

	#### TODO: Update this comment
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
history-ignore-command history-{enable,disable,toggle}

## Setup history parameters
HISTSIZE=1000000   # Maximum number of history events. It's large so we can use ancient commands
SAVEHIST=$HISTSIZE # How many events to write when saving; Set to HISTSIZE to ensure we save 'em all
# HISTFILE=...     # HISTFILE is already setup within `posix/.posix_rc`.

## Setup history options
setopt HIST_REDUCE_BLANKS     # Remove extra whitespace between arguments.
setopt HIST_NO_STORE          # Don't store the `history` command, or `fc -l`.
setopt HIST_IGNORE_SPACE      # Don't store commands that start with a space.
setopt HIST_IGNORE_DUPS       # Don't store commands that're identical to the one before.
setopt HIST_EXPIRE_DUPS_FIRST # When trimming, delete duplicates commands first, then uniques.
setopt HIST_FCNTL_LOCK        # Use `fcntl` to lock files. (Supported by all modern computers.)

## Disable options that might've been set
unsetopt HIST_IGNORE_ALL_DUPS # Ensure that non-contiguous duplicates are kept around.
unsetopt HIST_SAVE_NO_DUPS    # (This is just `HIST_IGNORE_ALL_DUPS` but for saving.)
unsetopt NO_APPEND_HISTORY    # Ensure we append to the history file when saving, not overwrite it.
unsetopt SHARE_HISTORY        # Don't constantly share history across interactive shells

# Don't record the `h` or `SampShell-history` functions
alias h='noglob SampShell-history'
history-ignore-command h SampShell-history

####################################################################################################
#                                                                                                  #
#                                               Jobs                                               #
#                                                                                                  #
####################################################################################################
	
## Setup job options (jobs programs in the background, started by eg `echo hi &`)
setopt AUTO_CONTINUE           # Always send `SIGCONT` when disowning jobs, so they run again.
unsetopt NO_CHECK_JOBS         # Confirm before exiting the shell if there's suspended jobs
unsetopt NO_CHECK_RUNNING_JOBS # Same as CHECK_JOBS, but also for running jobs.
unsetopt NO_HUP                # When the shell closes, send SIGHUP to all remaining jobs.

## Same as `jobs -d`, except the directories are on the same line as the jobs themselves
function jobs {
	emulate -L zsh
	builtin jobs -d $@ | command -p paste - -
	# builtin jobs -d $@ | sed 'N;s/\n/ /'
}

####################################################################################################
#                                                                                                  #
#                                     The Prompt: PS1 and RPS1                                     #
#                                                                                                  #
####################################################################################################

# Default zstyle for prompt
zstyle ':sampshell:prompt:git:*' pattern "$(whoami)/????-??-??"

## Options for prompt expansion
setopt PROMPT_SUBST        # Lets you use variables and $(...) in prompts.
unsetopt PROMPT_BANG       # Don't make `!` mean history number; we do this with %!.
unsetopt NO_PROMPT_PERCENT # Ensure `%` escapes in prompts are enabled.
unsetopt NO_PROMPT_{CR,SP} # Ensure a `\r` is printed before a line starts

## Load in the definitions for the `PS1` and `RPS1` variables
source $SampShell_ROOTDIR/zsh/prompt/ps1.zsh
source $SampShell_ROOTDIR/zsh/prompt/rps1.zsh

## Ensure that commands don't have visual effects applied to their outputs. `POSTEDIT` is a special
# variable that's printed after a command's been accepted, but before its execution starts. Here, it
# is set to an escape sequence which resets visual effects.
POSTEDIT=$'\e[m'

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
setopt RC_EXPAND_PARAM      # `ary=(x y z); echo a${ary}b` is `axb ayb azb`.
setopt MAGIC_EQUAL_SUBST    # Supplying `a=b` on the command line does `~`/`=` expansion
setopt GLOB_STAR_SHORT      # Enable the `**.c` shorthand for `**/*.c`
setopt EXTENDED_GLOB        # Always have extended globs enabled, without needing to set it.
unsetopt NO_EQUALS          # Enables `=foo`, which expands to the full path eg `/bin/foo`
unsetopt NO_SHORT_LOOPS     # Allow short-forms of commands, eg `for x in *; echo $x`

## "Safety" options
setopt NO_CLOBBER       # Don't overwrite files when using `>` (unless `>|` or `>!` is used.)
setopt CLOBBER_EMPTY    # Modify `NO_CLOBBER` to let you clobber empty files.
unsetopt RM_STAR_SILENT # In case it's accidentally unset, force `rm *` to ask for confirmation

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
	autoload -Uz $1/*
	local fn
	for fn in $1/*(:t); do
		zle -N $fn
	done
} $SampShell_ROOTDIR/zsh/widgets

## Create a new keymap called `sampshell` based off emacs, then set it as the main one.
bindkey -N sampshell emacs
bindkey -A sampshell main

## Bind key strokes to do functions
bindkey '^[#'    pound-insert
bindkey '^[='    SampShell-delete-to-char
bindkey '^[+'    SampShell-zap-to-char
bindkey '^[/'    SampShell-delete-path-segment
bindkey '^S'     SampShell-strip-whitespace && : # stty -ixon # need `-ixon` to use `^S`
bindkey '^[^[[A' SampShell-up-directory
bindkey '^[c'    SampShell-add-pbcopy
bindkey '^X^R'   redo
bindkey '^XR'    redo
bindkey '^Xr'    redo
alias which-command=which # for `^[?`

# "command-space" commands
bindkey '^[ %' SampShell-make-prompt-simple
bindkey '^[ $' SampShell-make-prompt-simple
bindkey '^[ z' SampShell-put-back-zle
bindkey '^[ p' SampShell-add-pbcopy
bindkey '^[ t' SampShell-transpose-words
bindkey -s '^[ l' '^Qls^M'

## up and down history, but without going line-by-line
bindkey '^P' up-history
bindkey '^N' down-history

# Arrow keys that can be used in the future
bindkey '^[[1;2C' undefined-key # Terminal.app's default sequence for "SHIFT + RIGHT ARROW"
bindkey '^[[1;2D' undefined-key # Terminal.app's default sequence for "SHIFT + LEFT ARROW"
bindkey '^[[1;5A' up-history    # (Added as a custom sequence for "CTRL + UP ARROW")
bindkey '^[[1;5B' down-history  # (Added as a custom sequence for "CTRL + DOWN ARROW")
bindkey '^[[1;5C' undefined-key # Terminal.app's default sequence for "CTRL + RIGHT ARROW"
bindkey '^[[1;5D' undefined-key # Terminal.app's default sequence for "CTRL + LEFT ARROW"
bindkey '^[[H'    undefined-key # TODO: Add into terminal.app as a sequence for `HOME`
bindkey '^[[E'    undefined-key # TODO: Add into terminal.app as a sequence for `END`

####################################################################################################
#                                                                                                  #
#                                           Autocomplete                                           #
#                                                                                                  #
####################################################################################################
## TODO:
autoload -U compinit
[[ ! -e $SampShell_CACHEDIR ]] && mkdir "$SampShell_CACHEDIR"
if [[ -f $SampShell_CACHEDIR/.zcompdump ]] then
	compinit -d $SampShell_CACHEDIR/.zcompdump
else
	compinit
fi

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
. $SampShell_ROOTDIR/zsh/completion.zsh
# zstyle ':completion:*:files' file-sort '!ignored-patterns '*.DS_Store'

####################################################################################################
#                                                                                                  #
#                                       Experimental Config                                        #
#                                                                                                  #
####################################################################################################

## Load "experimental" options---things I'm not sure yet about.
[[ -n $SampShell_EXPERIMENTAL ]] && source $SampShell_ROOTDIR/zsh/experimental.zsh

####################################################################################################
#                                                                                                  #
#                                          Git Shorthands                                          #
#                                                                                                  #
####################################################################################################
source $SampShell_ROOTDIR/zsh/git.sh

####################################################################################################
#                                                                                                  #
#                                      Functions and Aliases                                       #
#                                                                                                  #
####################################################################################################

## All helper functions and aliases should be defined here.
source $SampShell_ROOTDIR/zsh/utils.zsh
