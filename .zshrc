#### Basic SampShell definitions for interactive ZSH shell instances.
# This file shouldn't be sourced directly; instead, the top-level `.shrc` file sources it.
#
# The definitions in this file aren't really meant to be changed, as they codify how I use ZSH. Any
# options I'm not certain about go into `experimental.zsh`, which is `source`d unless the variable
# `$SampShell_no_experimental` is set to a nonempty value.
#
# This file is not the location for functions, but rather configuration; Functions go into the
# `utils.zsh` or `functions.zsh` files instead.
#
# Note that `setopt` is used for setting options to a value other than their default; `undo.zsh`
# is where `unsetopt` is used to set options back to their default in case something changed them.
# While not required (`setopt no_...` is the same as `unsetopt ...`), I find it easier to reason
# about this way.
#
# Note: This file intentionally doesn't start with a `.`, as it's not meant to be used directly as
# a user's `.zshrc`. (Instead, `source` the top-level `.shrc` file if needed.)
#####

# If SampShell_DISABLED is set to a non-empty value, then don't do any setup
if [[ -n $SampShell_DISABLED ]] return

# Load universal sampshell config; `SampShell_ROOTDIR` should already have been set.
emulate sh -c '. "${SampShell_ROOTDIR:?}/.shrc"'

hash -d ss=$SampShell_ROOTDIR

# Undo `setopt`s that might've been done
source ~ss/zsh/undo.zsh

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
# the functions, `-z` specifies they're autoloaded in ZSH-style, not KSH.)
typeset -Ua fpath=( ~ss/zsh/{functions,widgets,zsh_directory_name_functions} $fpath ) # add to fpath so `freload` works
autoload -Uz ~ss/zsh/{functions,widgets,zsh_directory_name_functions}/*

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

[[ -n $SampShell_TRASHDIR ]] && add-named-dir trash=$SampShell_TRASHDIR
[[ -d ~/tmp               ]] && add-named-dir tmp=$HOME/tmp
[[ -d ~/Desktop           ]] && add-named-dir d=$HOME/Desktop
[[ -d ~/Downloads         ]] && add-named-dir dl=$HOME/Downloads

## Have `d` act like `dirs`, except it also lists line numbers; Passing any args disables this.
function d { builtin dirs ${@:--v} }

## Setup `cd` options
setopt CDABLE_VARS  # Adds `cd var` as a shorthand for `cd $var` and `cd ~var`.
setopt AUTO_PUSHD   # Have `cd` push directories onto the directory stack like `pushd`
setopt CHASE_LINKS  # Ensure symlinks are always resolved when changing directories.

## Setup `~[dir]` expansions
typeset -Ua zsh_directory_name_functions
zsh_directory_name_functions+=( ~ss/zsh/zsh_directory_name_functions/*(:t) )

# Change the `cd` function to let you cd to a file if it is the only argument to `cd`.
function cd {
	[[ $# == 1 && -f $1 ]] && set -- $1:h
	builtin cd $@
}

####################################################################################################
#                                                                                                  #
#                                             History                                              #
#                                                                                                  #
####################################################################################################

## Load in the "record every command" functionality, unless it's been explicitly opted out of
if zstyle -T ':sampshell:history:record-every-command' enabled; then
	source ~ss/zsh/record-every-command.zsh
fi

## Setup history parameters
HISTSIZE=1000000   # Maximum number of history events. It's large so we can use ancient commands
SAVEHIST=$HISTSIZE # How many events to write when saving; Set to HISTSIZE to ensure we save 'em all
# HISTFILE=...     # HISTFILE is already setup within `posix/.shrc`.

## Setup history options
setopt HIST_REDUCE_BLANKS     # Remove extra whitespace between arguments.
setopt HIST_NO_STORE          # Don't store the `history` command, or `fc -l`.
setopt HIST_IGNORE_SPACE      # Don't store commands that start with a space.
setopt HIST_IGNORE_DUPS       # Don't store commands that're identical to the one before.
setopt HIST_EXPIRE_DUPS_FIRST # When trimming, delete duplicates commands first, then uniques.
setopt HIST_FCNTL_LOCK        # Use `fcntl` to lock files. (Supported by all modern computers.)

# Ignore commands by just prepending a space to them. This probably breaks on some commands, but I
# haven't figured them out yet.
function history-ignore-command {
	local cmd
	for cmd do
		alias -- "$cmd= $(whence -- "$cmd")"
	done
}

alias h='noglob h'
history-ignore-command h history-{enable,disable}

####################################################################################################
#                                                                                                  #
#                                               Jobs                                               #
#                                                                                                  #
####################################################################################################
	
## Setup job options (jobs programs in the background, started by eg `echo hi &`)
setopt AUTO_CONTINUE # Always send `SIGCONT` when disowning jobs, so they run again.

## Same as `jobs -d`, except the directories are on the same line as the jobs themselves
function j { jobs -ld $@ | paste - - } # Also coulda used 'N;s/\n/ /'

####################################################################################################
#                                                                                                  #
#                                     The Prompt: PS1 and RPS1                                     #
#                                                                                                  #
####################################################################################################

# Default zstyle for prompt
zstyle ':sampshell:prompt:git:*' pattern "$(whoami)/????-??-??" # for old one
zstyle ':prompt:sampshell:git:*' pattern "$(whoami)/????-??-??"
zstyle ':prompt:sampshell:time' format '%*'

fpath+=( ~ss/zsh/prompt )
autoload -Uz promptinit && promptinit
prompt sampshell

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
setopt NO_CLOBBER       # Don't overwrite files when using `>` (unless `>|` or `>!` is used.)
setopt CLOBBER_EMPTY    # Modify `NO_CLOBBER` to let you clobber empty files.

####################################################################################################
#                                                                                                  #
#                                           Key Bindings                                           #
#                                                                                                  #
####################################################################################################

alias bk='noglob bindkey'
alias bkg='bindkey | noglob fgrep -ie'
alias which-command=which # for `^[?`

# function bindkey { print "bindkey: $*"; builtin bindkey $@ }

source ~ss/zsh/keybinds.zsh

####################################################################################################
#                                                                                                  #
#                                           Autocomplete                                           #
#                                                                                                  #
####################################################################################################
source ~ss/zsh/completion.zsh

####################################################################################################
#                                                                                                  #
#                                       Experimental Config                                        #
#                                                                                                  #
####################################################################################################

## Load "experimental" options---things I'm not sure yet about.
[[ -n $SampShell_EXPERIMENTAL ]] && source ~ss/zsh/experimental.zsh

####################################################################################################
#                                                                                                  #
#                                          Git Shorthands                                          #
#                                                                                                  #
####################################################################################################
source ~ss/zsh/git.zsh

####################################################################################################
#                                                                                                  #
#                                      Functions and Aliases                                       #
#                                                                                                  #
####################################################################################################

## All extra unsorted functions and aliases should be defined here.
source ~ss/zsh/misc.zsh

## What follows are functions/aliases I use commonly enough

# Shorthands for redirecting to `/dev/null`
alias -g @N='>/dev/null'
alias -g @2N='2>/dev/null'

alias '%= ' '$= ' # Let's you paste commands in; a start `$` or `%` on its own is ignored.

function reload {
	# exec =zsh -il
	local opts=-i
	if [[ $options[login] == on ]] opts+=l
	exec =zsh $opts
}
function freload { unfunction $@ && autoload -zU $@; print "reloaded: $@" }

# Copies the current directory, or a subdirectory of the current direcotry if given
function pwdc () (
	if (( $ARGC > 1 )); then print "at most 1 argument allowed" @2N; return 1 ; fi
	cd -q -- "$PWD${1+/$1}" && pbc "$PWD"
)

# Shorthand for looking for processes
function pg  { pgrep -afl $@ | command grep --color=always $@ }
function pk  { pkill -afl $@ } # IDK if these always kill the right processes...
function pk9 { pkill -KILL -afl $@ }

# Interact with zsh files
function szfiles {
	if (( ARGC != 0 )) { print @2N exactly 0 args must be given; return 1 }
	subl ${ZDOTDIR:-~}/.z(shenv|shrc|profile|login|logout)
}

function szrc { subl ~/.zshrc }
function zfns { typeset -m '*_functions' }
