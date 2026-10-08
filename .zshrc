#### SampShell's core config for interactive ZSH sessions
# This file is the stable foundation for my ZSH setup---it changes rarely, should be correct, and
# must work on every system that runs a modern ZSH. Everything that it sources (barring `.shrc`) is
# less stable, and is subject to change.
#
# ZSH inherits from `.shrc` (where options that all POSIX shells can understand); this file is where
# ZSH-only config is defined. Anything I'm uncertain about is guarded via `$SampShell_EXPERIMENTAL`,
# which defaults to being enabled.
#
# This file is a mix of ZSH setup (path/fpath, options, etc.) and common functions/aliases that are
# used constantly and rarely change.
#
# Note that `setopt` is used for setting options to a value other than their default; `undo.zsh`
# is where `unsetopt` is used to set options back to their default in case something changed them.
# While not required (`setopt no_...` is the same as `unsetopt ...`), I find it easier to reason
# about this way.
####

# If SampShell_DISABLED is set to a non-empty value, then don't do any setup
if [[ -n $SampShell_DISABLED ]]; then
	return
fi

## Load universal sampshell config that all POSIX shells share.
# (Note that `SampShell_ROOTDIR` should already have been set in the `.profile`, so we `:?` as just
# a sanity check)
emulate sh -c '. "${SampShell_ROOTDIR:?}/.shrc"'

## Adds `ss` as a named directory, as it's used heavily in this config file
hash -d ss=$SampShell_ROOTDIR

# Undo `setopt`s that might've been done
source ~ss/zsh/undo.zsh

####################################################################################################
#                                                                                                  #
#                                           Setup $PATH                                            #
#                                                                                                  #
####################################################################################################

typeset -xgU path # Ensure `path` is unique, and export it (in case it wasn't already).

####################################################################################################
#                                                                                                  #
#                                   Add in autoloaded functions                                    #
#                                                                                                  #
####################################################################################################

## Standardize `fpath`. (`-g` and `-a` are sanity checks; `-U` makes it unique)
# $fpath is where we ZSH's `autoload` will search for functions. The idea here is to offload
# functions that are somewhat large, or don't need to be included in every startup, to their own
# files.
#
# Importantly though, these are functions that somehow interact with ZSH's internals (such as
# history functions, widgets, etc), and thus have to be ZSH. In general, we prefer sticking general
# purpose functions into `$PATH`, so that they can be used by other programs (or shells).
typeset -gaU fpath

# Adds a directory to the `fpath`, and then autoloads all functions in it. Sets `$reply` to the
# list of functions names that were autoloaded.
function autoload-dir {
	local dir=${1:?}
	reply=( $dir/*(.N:t) )

	if (( $#reply == 0 )) then
		print -ru2 "$0: no functions found in $dir"
		return 1
	fi

	fpath=( $dir $fpath )
	autoload -Uz $reply
}

# Load the general-purpose functions we use.
autoload-dir ~ss/zsh/functions

####################################################################################################
#                                                                                                  #
#                                           Directories                                            #
#                                                                                                  #
####################################################################################################

if [[ -n $SampShell_TRASHDIR ]] hash -d trash=$SampShell_TRASHDIR
if [[ -d ~/tmp               ]] hash -d tmp=$HOME/tmp
if [[ -d ~/Desktop           ]] hash -d d=$HOME/Desktop
if [[ -d ~/Downloads         ]] hash -d dl=$HOME/Downloads

## Have `d` act like `dirs`, except it also lists line numbers; Passing any args disables this.
function d { builtin dirs ${@:--v} }

## Setup `cd` options
setopt CDABLE_VARS  # Adds `cd var` as a shorthand for `cd $var` and `cd ~var`.
setopt AUTO_PUSHD   # Have `cd` push directories onto the directory stack like `pushd`
setopt CHASE_LINKS  # Ensure symlinks are always resolved when changing directories.
setopt PUSHD_MINUS  # Have `~-1` mean "the last dir", not `~+1`.

## Setup `~[dir]` expansions
() {
	autoload-dir ~ss/zsh/zdn || return
	local zdn
	for zdn in $reply; do
		add-zsh-hook zsh_directory_name $zdn
	done
}

## Change the `cd` function to let you cd to a file if it is the only argument to `cd`.
function cd {
	[[ $# == 1 && -f $1 ]] && set -- $1:h
	builtin cd $@
}

####################################################################################################
#                                                                                                  #
#                                             History                                              #
#                                                                                                  #
####################################################################################################

# Autoload any relevant history functions
autoload-dir ~ss/zsh/functions/history

## Load in the "record every command" functionality, unless it's been explicitly opted out of
if zstyle -T ':sampshell:history:record-every-command' enabled; then
	## Add the record history function to the end.
	# Ideally, it's the last function, so that it only records commands that all previous history
	# functions accepted. However, being last isn't critical (it's only used in statistics), so it's
	# fine if other functions are added after it.
	add-zsh-hook zshaddhistory _SampShell-record-every-command
fi

## Setup history parameters
HISTSIZE=1000000   # Maximum number of history events. It's large so we can use ancient commands
SAVEHIST=$HISTSIZE # How many events to write when saving; Set to HISTSIZE to ensure we save 'em all
: "${HISTFILE:=${ZDOTDIR:-$HOME}/.zsh_history}" # Save history to ~/.zsh_history by default

## Setup history options
setopt APPEND_HISTORY         # Append history in $HISTFILE, not overwrite (this is a zsh default)
setopt HIST_REDUCE_BLANKS     # Remove extra whitespace between arguments.
setopt HIST_NO_STORE          # Don't store the `history` command, or `fc -l`.
setopt HIST_IGNORE_SPACE      # Don't store commands that start with a space.
setopt HIST_IGNORE_DUPS       # Don't store commands that're identical to the one before.
setopt HIST_EXPIRE_DUPS_FIRST # When trimming, delete duplicate commands first, then uniques.
setopt HIST_FCNTL_LOCK        # Use `fcntl` to lock files. (Supported by all modern OSes.)

unsetopt SHARE_HISTORY INC_APPEND_HISTORY INC_APPEND_HISTORY_TIME # In case someone enables them

## Helpers
alias h='noglob h'
history-ignore-command h history-{enable,disable} flush-history

####################################################################################################
#                                                                                                  #
#                                               Jobs                                               #
#                                                                                                  #
####################################################################################################

## Setup job options
setopt AUTO_CONTINUE # Always send `SIGCONT` when disowning jobs, so they run again.

## Same as `jobs -d`, except the directories are on the same line as the jobs themselves
unalias j 2>/dev/null
function j { jobs -ld $@ | paste - - } # Also coulda used `sed 'N;s/\n/ /'`

####################################################################################################
#                                                                                                  #
#                                     The Prompt: PS1 and RPS1                                     #
#                                                                                                  #
####################################################################################################

# `promptinit` does all the autoload itself
fpath+=~ss/zsh/functions/prompt

# Default zstyle for prompt
zstyle ':prompt:sampshell:git:*' pattern "$USERNAME?[0-9]???-??-??"

autoload -Uz promptinit && promptinit
() {
	local prompt_style
	zstyle -s ':sampshell:interactive:prompt' style prompt_style || prompt_style=default
	prompt sampshell $prompt_style
	setopt TRANSIENT_RPROMPT # Unfortunately, this can't be set in the prompt :-(
}

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

## Options that modify valid syntax
setopt INTERACTIVE_COMMENTS # Enable comments in interactive shells; I use this all the time
setopt RC_QUOTES            # Within `'` strings, `''` is interpreted as an escaped `'`.
setopt RC_EXPAND_PARAM      # `ary=(x y z); echo a${ary}b` is `axb ayb azb`.
setopt MAGIC_EQUAL_SUBST    # Supplying `a=b` on the command line does `~`/`=` expansion
setopt GLOB_STAR_SHORT      # Enable the `**.c` shorthand for `**/*.c`
setopt EXTENDED_GLOB        # Always have extended globs enabled, without needing to set it.

## "Safety" options
setopt NO_CLOBBER    # Don't overwrite files when using `>` (unless `>|` or `>!` is used.)
setopt CLOBBER_EMPTY # Modify `NO_CLOBBER` to let you clobber empty files.

####################################################################################################
#                                                                                                  #
#                                           Key Bindings                                           #
#                                                                                                  #
####################################################################################################

alias bk='noglob bindkey'
alias bkg='bindkey | noglob grep -Fie'
alias bkgd='clzsh -- -ic bindkey | noglob grep -Fie'
alias which-command=which # for `^[?`

# function bindkey { print "bindkey: $*"; builtin bindkey $@ } # Helper for showing keybinds
source ~ss/zsh/keybinds.zsh

####################################################################################################
#                                                                                                  #
#                                           Autocomplete                                           #
#                                                                                                  #
####################################################################################################

autoload -Uz compinit
if [[ ! -e ${XDG_STATE_HOME:=~/.local/state}/sampshell ]] mkdir "$XDG_STATE_HOME/sampshell"
compinit -d $XDG_STATE_HOME/sampshell/.zcompdump

zstyle ':completion:*' use-compctl false # never use old-style completion

if [[ $VENDOR = apple ]] then
	zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case-insensitive for tab completion
	fignore+=(.DS_Store) # boo, DS_Store files!
fi

zmodload -i zsh/complist # May not be required
zstyle ':completion:*' list-colors '' # Add colours to completions
zstyle ':completion:*:*:cd:*' file-sort modification
# zstyle ':completion:*:*:rm:*' completer _ignored <-- why delete
zstyle ':completion:*:files' ignored-patterns '(*/|).DS_Store'
# zstyle ':completion:*:files' file-sort '!ignored-patterns' '*.DS_Store' <-- TODO

####################################################################################################
#                                                                                                  #
#                                       Experimental Config                                        #
#                                                                                                  #
####################################################################################################

## Load "experimental" options---things I'm not sure about yet.
if [[ -n $SampShell_EXPERIMENTAL ]] then
	## Options I'm not sure if I want to set or not.
	# [[ -n $ENV ]] && emulate sh -c '. "${(e)ENV}"' # <-- TODO, do we want ENV

	: "${REPORTTIME:=4}" # Print the duration of commands that take more than 4s of CPU time

	setopt EXTENDED_HISTORY     # (For fun) When writing cmds, write their start time & duration too.
	setopt COMPLETE_IN_WORD
	setopt CORRECT                 # Correct commands when executing.
	setopt NO_CASE_GLOB CASE_PATHS # Enable case-insensitive globbing, woah!

	CORRECT_IGNORE='(_*|[^[:space:]]# \(\))' # Don't correct to functions starting with `_`

	: command_not_found_handler # <-- thing executed when a command's not found
fi

####################################################################################################
#                                                                                                  #
#                                          Git Shorthands                                          #
#                                                                                                  #
####################################################################################################

## Shorthand and spellcheck
alias g=git gti=git

## Make `g<cmd>` aliases for all git aliases defined. Explicitly skips ones with `-` ("long-form").
# Also intentionally not specific to sampshell aliases, this'll load any other git aliases defined.
() {
	local cmd
	for cmd in $(git config --name-only --get-regexp '^alias\.[^-]+$'); do
		cmd=${cmd#alias.}
		alias "g$cmd=git $cmd"
	done
}

## ZSH-specific aliases
alias gcm='noglob git commit-msg'
alias gcma='gcm --amend'
alias gcmn='gcm --no-verify'
alias gcman='gcm --amend --no-verify' gcmna=gcman
alias gnb='noglob git new-branch'

# Git shorthand, make `@-X` be the same as `@{-X}`.
alias -g '@-1=@{-1}' '@-2=@{-2}' '@-3=@{-3}' \
         '@-4=@{-4}' '@-5=@{-5}' '@-6=@{-6}' \
         '@-7=@{-7}' '@-8=@{-8}' '@-9=@{-9}'

# }source ~ss/zsh/git-alias.zsh

####################################################################################################
#                                                                                                  #
#                                      Functions and Aliases                                       #
#                                                                                                  #
####################################################################################################

## Few notes:
# 1. Functions here use `function ... { ... }` to prevent clashes with existing aliases
# 2. These declarations are the smaller and more "stable" ones I use often; ones I don't go into
#    zsh/misc.zsh.

## All extra unsorted functions and aliases should be defined here.
source ~ss/zsh/misc.zsh

# Shorthands for redirecting to `/dev/null`
alias -g @N='>/dev/null'
alias -g 2@N='2>/dev/null'
alias -g @@='&>/dev/null'

alias '%= ' '$= ' # Lets you paste commands in; a starting `$` or `%` on its own is ignored.
history-ignore-command reload

# Wait until a pid finishes
function wait-for-pid {
	local pid=${1:?need a pid}
	local time=${2:-5}

	while kill -0 $pid 2>/dev/null; do
		sleep $time
	done
}

# Copies the current directory, or a subdirectory of the current directory if given
function pwdc () (
	if (( $# > 1 )) then
		print -u2 "$0: at most 1 argument allowed"
		return 1
	fi

	cd -q -- "$PWD${1+/$1}" && pbc "$PWD"
)

# Shorthand for looking for processes
function pg  { pgrep -fl $@ | command grep --color=always $@ }
function pk  { pkill -fl $@ } # IDK if these always kill the right processes...
function pk9 { pkill -KILL -fl $@ }

# Interact with zsh files
function szfiles {
	if (( $# != 0 )) then print -u2 "$0: takes no arguments"; return 1; fi
	$SampShell_EDITOR ${ZDOTDIR:-~}/.z(shenv|shrc|profile|login|logout)
}

function szrc { $SampShell_EDITOR ${ZDOTDIR:-~}/.zshrc }
function zfns { typeset -m '*_functions' }
sublf () $SampShell_EDITOR "$(type ${1:?} | awk '{print $NF}')" # open file containing shell command

# Adds in "clean shell" aliases, which start up a clean version of shells, and only set "normal"
# vars such as $TERM/$HOME etc. Relies on my `clean-shell` function being in `$PATH`.
alias   clsh='clean-shell sh'
alias clbash='clean-shell bash'
alias  clzsh='clean-shell zsh'
alias cldash='clean-shell dash'

## Banner utility
alias banner='noglob ~ss/bin/universal/banner'
alias b80='banner --copy --width=80'
alias b100='banner --copy --width=100'

## Adding default arguments to builtin commands
alias grep='grep --color=auto'
alias fgrep='grep -F --color=auto'
alias egrep='grep -E --color=auto'

function hr { xx ${@:--} }
function hrc { hr "$@" | pbc }
function ncol { awk "{ print \$${1:?} }" }

# `prp` is a shorthand for `print -P`, which prints out a fmt string as if it were in the prompt.
alias prp='print -P'  # NOTE: You can also use `print ${(%)@}`

# TODO: investigate this more. Maybe `du -chd1`?
function ducks { du -chs -- ${@:-*} | sort -h }
function awkf () awk "BEGIN{${(j:;:)@}; exit}"
if [[ $VENDOR = apple ]] alias cpu='top -o cpu' # TODO: maybe `ps -Ao pcpu,pid,comm | sort -nr | head ...`

function paa {
	local -A ary=( ${(kvP)1} )
	local k v MBEGIN MEND MATCH
	local max_len=${${(*Onk)ary/(#m)*/$MEND}[1]}
	foreach k v ( ${(kv)ary} ) {
		printf ' %*s: ' $max_len "$k"
		p --no-prefixes --trailing-newline -- "$v"
	}
}
