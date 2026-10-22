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
#                                            Load Paths                                            #
#                                                                                                  #
####################################################################################################

## Ensure `path` is unique, and export it (in case it wasn't already).
# (Note that SampShell only adds to `$PATH` in login shells; cf `.zprofile` / `.profile`.)
typeset -xgU path

## Standardize `fpath`. (`-g` and `-a` are sanity checks; `-U` makes it unique)
# $fpath is where we ZSH's `autoload` will search for functions. The idea here is to offload
# functions that are somewhat large, or don't need to be included in every startup, to their own
# files.
#
# Importantly though, these are functions that somehow interact with ZSH's internals (such as
# history functions, widgets, etc), and thus have to be ZSH. In general, we prefer sticking general
# purpose functions into `$PATH`, so that they can be used by other programs (or shells).
typeset -gaU fpath

## Add all SampShell features to `fpath`, so later `autoload`s can handle them
fpath=( ~ss/zsh/{functions,hooks,widgets,prompt} $fpath )

## Autoload `add-zsh-hook` for later use
autoload -Uz add-zsh-hook

# Autoload normal ZSH functions I use
autoload -Uz ~ss/zsh/functions/*(.)

####################################################################################################
#                                                                                                  #
#                                           Directories                                            #
#                                                                                                  #
####################################################################################################

## Add names directories for common locations, if they exist
if [[ -d ~/tmp       ]] hash -d tmp=~/tmp
if [[ -d ~/Desktop   ]] hash -d d=~/Desktop
if [[ -d ~/Downloads ]] hash -d dl=~/Downloads

## Overwrite `dirs` to always pass `-v`; passing any args disables this.
function dirs { builtin dirs "${@:--v}" }

## Setup `cd` options
setopt CDABLE_VARS  # Adds `cd var` as a shorthand for `cd $var` and `cd ~var`.
setopt AUTO_PUSHD   # Have `cd` push directories onto the directory stack like `pushd`
setopt CHASE_LINKS  # Ensure symlinks are always resolved when changing directories.
setopt PUSHD_MINUS  # Have `~-1` mean "the last dir", not `~+1`.

## Setup `~[dir]` expansions
add-zsh-hook -Uz zsh_directory_name zdn-repo-root # `~[rr]` is the repo root

## Change the `cd` function to let you cd to a file if it is the only argument to `cd`.
function cd {
	[[ $# == 1 && -f $1 ]] && set -- $1:h
	builtin cd "$@"
}

####################################################################################################
#                                                                                                  #
#                                             History                                              #
#                                                                                                  #
####################################################################################################

## Overview of how I use history
# The way I use history is pretty specific: Every ZSH instance's history is unrelated to every other
# instance's history (i.e. they don't share history _at all_), and only on shutdown (or an explicit
# `history-flush` call), do they write to the shared history file. This heavily influences the
# "saving" options. Note that macOS's Terminal.app's builtin session save mechanism actually fits
# quite nicely into this, and I don't have to touch it at all (except for `history-flush`). Clean!
#
# Additionally, I like to use history as a chunk of contiguous commands (so I can CTRL+R to search
# for commands, and CTRL+O to then execute the next one), but their relative order does not matter
# much to me. On top of that, modern computers can easily store any amount of history commands,
# so I explicitly set `HISTSIZE` and `SAVEHIST` to very large numbers, so I never run out of space,
# and most "how do deal with duplicates" options that ZSH uses aren't too relevant.
#
# I do like to omit commands from being stored in history, though. This is done by enabling the
# `HIST_IGNORE_SPACE` option, so prepending spaces skips adding a command to history. Some commands
# I don't want to add to history ever for some reason or other, so `history-ignore-command` can
# prevent them from ever being recorded (by essentially aliasing commands to prepend a space).
#
# I also want to record every non-ignored command (for statistical purposes), so the
# `_SampShell-record-every-command` function is used to record things as needed.
##

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

unsetopt SHARE_HISTORY INC_APPEND_HISTORY INC_APPEND_HISTORY_TIME # In case someone enables them

## Setup builtin `h`; TODO, clean this way up.
if [[ -n $SampShell_EXPERIMENTAL ]]; then
	unfunction h
	autoload h
	alias h='noglob h'
fi

## Don't record some commands in history
# I've gone though many iterations of this concept, including:
# - An initial hacky `HISTORY_IGNORE` that required adding parens around everything. But, 'twas too
#   fragile, and didn't prevent populating the in-history buffer, so it wasn't clear which commands
#   would be ignored or not.
# - Adding custom `zshaddhistory_functions` hooks. Unfortunately, This required the hook to always
#   be first, which isn't easily enforced, and anything added before it---including defining the
#   `zshaddhistory` function itself---would be entirely blind to it.)
# - A failed attempt to use `zstyle` to specify which commands are ignored, which also required
#   using `zshaddhistory` hooks.
# - Prepending every ignored command with a space (`alias "$cmd= $cmd"`), and ensuring that
#   `HIST_IGNORE_SPACE` was set. While this mostly worked, `type <ignored cmd>` isn't very usable
#   (it shows its an alias), and didn't work too well with `_SampShell-record-every-command`. The
#   nail in its coffin was realizing that multiple commands on one line would mark the entire
#   line as entirely ignored (`foo ; ignored-cmd ; bar`), which wasn't ideal.
#
# I ended up realizing that the relaxing the previous requirement of "ignoring a command means that
# SHOULD NEVER, HARD STOP, appear in any history file" to a simpler best-effort of "don't write
# noisy/unnecessary commands to a history file" (while still keeping the `alias "$cmd= $cmd"` trick
# in my back pocket in case I ever needed to SHOULD NEVER record a command).
#
# The current implementation relies on a combination of `HISTORY_IGNORE` and a `zshaddhistory` hook:
# The hook (`dont-record-ignored-commands`) is a best-attempt at preventing some commands from being
# recorded, but prior hooks and a `zshaddhistory` function itself can circumvent it, which is where
# `HISTORY_IGNORE` comes into play: It's a backup that ensure that regardless of what history hooks
# exist, these "noisy" commands won't eventually be written to the history file.
##

# Declare `HISTORY_IGNORE` as a tied variable, which lets us manipulate `history_ignore` (an array)
# as much as we want, and all the elements are joined together with pipes (to delineate patterns).
typeset -TU HISTORY_IGNORE history_ignore '|'

# Adds the command(s) to the list of ignored commands---note that it escapes all the command names,
# since it's supposed to be a pattern. To add a pattern, just append to `history_ignore` directly.
function history-ignore-command { history_ignore+=( ${(b)@} ) }

# Don't record commands which match `HISTORY_IGNORE`, after stripping trailing and leading space.
function dont-record-ignored-commands {
	[[ ${(*)${(*)1%%[[:space:]]#}##[[:space:]]#} != ${~HISTORY_IGNORE} ]]
}
add-zsh-hook zshaddhistory dont-record-ignored-commands

## Ignore these history commands
history-ignore-command h history-{enable,disable,flush}

## Load in the "record every command" functionality, unless it's been explicitly opted out of
if zstyle -T ':sampshell:history:record-every-command' enabled; then
	## Add the record history function to the end.
	# Ideally, it's the last function, so that it only records commands that all previous history
	# functions accepted. However, being last isn't critical (it's only used in statistics), so it's
	# fine if other functions are added after it.
	add-zsh-hook zshaddhistory _SampShell-record-every-command
fi


####################################################################################################
#                                                                                                  #
#                                               Jobs                                               #
#                                                                                                  #
####################################################################################################

## Setup job options
setopt AUTO_CONTINUE # Always send `SIGCONT` when disowning jobs, so they run again.

## Same as `jobs -d`, except the directories are on the same line as the jobs themselves
function j { jobs -ld $@ | paste - - } # Also coulda used `sed 'N;s/\n/ /'`

####################################################################################################
#                                                                                                  #
#                                     The Prompt: PS1 and RPS1                                     #
#                                                                                                  #
####################################################################################################

# `promptinit` does all the autoloading of prompt themes itself
autoload -Uz promptinit && promptinit
() {
	local prompt_style
	zstyle -s ':sampshell:interactive:prompt' style prompt_style || prompt_style=default
	prompt sampshell $prompt_style
}
setopt TRANSIENT_RPROMPT # Unfortunately, this can't be set in the prompt :-(

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
histchars[2]=, # Change from `^ehco^echo` to `,ehco,echo`; `^` is just so far away lol

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

## Global shorthands for redirecting to `/dev/null`
alias -g  @N='>/dev/null'
alias -g 2@N='2>/dev/null'
alias -g  @@='&>/dev/null'

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

## Unlike most other features of ZSH, I never got too deep into autocomplete. This section is
# ship-shod, and will be revisited once I get a better handle on how autocompletes work.

autoload -Uz compinit
compinit -d ${SampShell_CACHE_HOME:?}/.zcompdump

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
	source ~ss/zsh/experimental.zsh
fi

####################################################################################################
#                                                                                                  #
#                                          Git Shorthands                                          #
#                                                                                                  #
####################################################################################################

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
() {
	local i
	for i in {1..9}; alias -g "@-$i=@{-$i}"
}

####################################################################################################
#                                                                                                  #
#                             Enable External ZSH features, if present                             #
#                                                                                                  #
####################################################################################################

# Enable syntax highlighting and autosuggestion if they exist.
() {
	local prefix arg
	prefix=$(brew --prefix) || return
	for arg in $prefix/${^@}; do
		[[ -e $arg ]] && source $arg
	done
} share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  share/zsh-autosuggestions/zsh-autosuggestions.zsh

# TODO: I want this set on macos when highlights are installed. 
if false; then
	typeset -A ZSH_HIGHLIGHT_STYLES
	ZSH_HIGHLIGHT_STYLES[comment]='fg=240'
fi

####################################################################################################
#                                                                                                  #
#                                      Functions and Aliases                                       #
#                                                                                                  #
####################################################################################################

## Few notes:
# 1. Functions here use `function ...` to prevent clashes with existing aliases
# 2. These declarations are the smaller and more "stable" ones I use often; ones I don't go into
#    zsh/misc.zsh.

## Replace the current shell with a brand new ZSH. `reload` does normal shutdown procedures.
# This has to be an alias to get around a ZSH 5.9 bug relating to; the removal of `reload!` on
# exit failure is, eg, if we do `reload` when we still have active jobs.
alias reload='zshexit_functions+=reload!; exit || zshexit_functions=${zshexit_functions#:reload!}'
alias r!='reload!'
history-ignore-command reload{,!} r!

# Let you paste in commands that start with `$` or `%` (they're just ignored)
alias '%= ' '$= '

################################################################################
#                           clean up ones below here                           #
################################################################################

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
alias szrc='$SampShell_EDITOR ${ZDOTDIR:-~}/.zshrc'
alias szp='$SampShell_EDITOR ${ZDOTDIR:-~}/.zprofile'
alias szfiles='$SampShell_EDITOR ${ZDOTDIR:-~}/.z(shenv|shrc|profile|login|logout)'
function zfns { typeset -m '*_functions' }
function sublf () $SampShell_EDITOR ${functions_source[$1]:?}

# Adds in "clean shell" aliases, which start up a clean version of shells, and only set "normal"
# vars such as $TERM/$HOME etc. Relies on my `clean-shell` function being in `$PATH`.
alias   clsh='clean-shell sh'
alias clbash='clean-shell bash'
alias  clzsh='clean-shell zsh'
alias cldash='clean-shell dash'

## Banner utility
# Note that we have to explicitly specify the banner location, as macOS also ships with a banner
# utility (/usr/bin/banner). Even though we prepend our banner to `$PATH` normally, if macOS's
# `/usr/libexec/path_helper` command (which the default `/etc/zprofile` uses) is run _after_ we
# construct our path, it'll actually prepend its own `/usr/bin` to the start---yikes! Normally
# this doesn't matter, but when we `reload` the shell this does happen. The easiest workaround
# is to just explicitly specify the path here for `banner`; if I ever have more problems in
# the future, I might end up modifying `/etc/zprofile`, but I'd rather not futz with that right now.
alias banner='noglob ~ss/bin/universal/banner'
alias b80='banner --copy --width=80'
alias b100='banner --copy --width=100'

## Adding default arguments to builtin commands
alias grep='grep --color=auto'
alias fgrep='grep -F'
alias egrep='grep -E'

function hr { xx ${@:--} }
function hrc { hr "$@" | pbc }
function ncol { awk "{ print \$${1:?} }" }

# `prp` is a shorthand for `print -P`, which prints out a fmt string as if it were in the prompt.
alias prp='print -P'  # NOTE: You can also use `print ${(%)@}`

# TODO: investigate this more. Maybe `du -chd1`?
if [[ $VENDOR = apple ]] alias cpu='top -o cpu' # TODO: maybe `ps -Ao pcpu,pid,comm | sort -nr | head ...`

function wait-for-pid {
	local pid=${1:?need pid}
	local duration=${2:-5}
	while kill -0 $pid 2>/dev/null; do
		sleep $duration
	done
}

## All extra unsorted functions and aliases should be defined here.
source ~ss/zsh/misc.zsh
