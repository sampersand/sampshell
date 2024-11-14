## Outline
. ${0:P:h}/interactive-todos.zsh

## Add commonly-used aliases
[[ $VENDOR == apple ]] && eval "${$(alias -L ls)/ls/l}hGb" # add the `l` alias more options to `ls` which I know macOS supports
alias '%= ' '$= ' # `$` or `%` alone at he start of a line is ignored; lets you paste commands in.
alias d=dirs
alias mk=mkdir

# Reloads the shell by rerunning all the ~/.zxxx` scripts.
# TODO: should we also load in the system config?
function reload {
	for file in ${ZDOTDIR:-$HOME}/.z{shenv,profile,shrc,login}; do
		SampShell_dot_if_exists $file
	done
}

## Adds in "clean shell" functions, and the clsh alias
function clean-sh { clean-shell --shell "$(which sh)" $@ } # use which in case EQUALS is unset
function clean-zsh { clean-shell --shell "$(which zsh)" $@ }
function clean-bash { clean-shell --shell "$(which bash)" $@ }
SampShell_command_exists dash && function clean-dash { clean-shell --shell "$(which dash)" $@ }

alias clsh=clean-shell
clzsh () clean-zsh --none -- -fd $@ #absolutely nothing set, not even sampshell stuff

# The only git config we have is to add in a bunch of global aliases, which are
# used to reference older branches without having to type out the braces.
for i in {1..10}; do
	alias -g "@-$i=@{-$i}"
done


####################################################################################################
#                                        Named Directories                                         #
####################################################################################################
source ${0:P:h}/extended/named-directories.zs
[[ -n $SampShell_ROOTDIR  ]] && add-named-dir ss    $SampShell_ROOTDIR
[[ -n $SampShell_TMPDIR   ]] && add-named-dir tmp   $SampShell_TMPDIR
[[ -n $SampShell_TRASHDIR ]] && add-named-dir trash $SampShell_TRASHDIR
[[ -d ~/Desktop           ]] && add-named-dir d     ~/Desktop
[[ -d ~/Downloads         ]] && add-named-dir dl     ~/Downloads

####################################################################################################
#                                             History                                              #
####################################################################################################
source ${0:P:h}/extended/record-every-command.zsh

# `HISTFILE` is already set by posix stuff.
HISTSIZE=1000000   # Keep a lot so it's easy to refernece
SAVEHIST=$HISTSIZE # How many lines to save at the end

## History options
# setopt HIST_LEX_WORDS       # TODO: Is this option wanted?
setopt HIST_FCNTL_LOCK        # Use `fcntl` to lock files. (Supported by all modern computers.)
setopt HIST_REDUCE_BLANKS     # Remove extra whitespace between arguments
setopt HIST_ALLOW_CLOBBER     # Add `|` to `>` and `>>`, so that re-running the command can clobber.
setopt HIST_NO_STORE          # Don't store the `history` command, or `fc -l`.
setopt HIST_IGNORE_SPACE      # Don't store commands that start with a space.
setopt HIST_IGNORE_DUPS       # Don't commands that are duplicates of the immediately preceding one.
setopt HIST_EXPIRE_DUPS_FIRST # When trimming, delete duplicates commands first, then uniques.
setopt EXTENDED_HISTORY       # When saving, write the start time and duration as well.
unsetopt HIST_IGNORE_ALL_DUPS # In case it's set; I like having non-contiguous dups
unsetopt HIST_SAVE_NO_DUPS    # In case it's set; This is just HIST_IGNORE_ALL_DUPS but for saving.


# Enable and disable history
function disable-history { fc -p && SampShell_nosave_hist=1 && echo 'History saving disabled.' }
function enable-history { fc -P && SampShell_nosave_hist= && echo 'History saving enabled.' }

# Don't store enable-history or disable-history
zshaddhistory_functions[1,0]=(SampShell-nosave-enable-disable-history) # Put before record-every-command
function SampShell-nosave-enable-disable-history { [[ "${1%$'\n'}" != ((en|dis)able-history) ]] }

####################################################################################################
#                                           Command Line                                           #
####################################################################################################
## Command line
setopt INTERACTIVE_COMMENTS # I use this all the time
setopt RC_QUOTES            # Let you do '' to mean a single `'` within a `'` string
setopt MAGIC_EQUAL_SUBST    # Supplying `a=b` on the command line does `~`/`=` expansion
setopt BANG_HIST            # Lets you do `!!` and friends

## Inline history stuff
histchars[2]=, # because `^` is a pain

## Autocompletion
setopt AUTO_PARAM_KEYS      # The character added after autocomplete can be autodeleted
setopt AUTO_REMOVE_SLASH    # same with trailing `/`
# echo 'todo: autocompletion'

## Report times of commands that go long (cpu-wise); if it's unset then default to 5s.
: ${REPORTTIME=5}

####################################################################################################
#                                               Jobs                                               #
####################################################################################################
## Enable options. Note the `CHECK_XXX_JOBS` options could technically be in safety.zsh
setopt MONITOR            # Enable job control, in case it's not already sent
setopt AUTO_CONTINUE      # Always sent `SIGCONT` when disowning jobs, so they run again.
setopt CHECK_JOBS         # Confirm before exiting the shell if there's suspended jobs
setopt CHECK_RUNNING_JOBS # Same as CHECK_JOBS, but also for running jobs.
setopt HUP                # When the shell closes, send SIGUP to all jobs.

## Create the shorthand for `parallelize-it`
alias parallelize-it=SampShell_parallelize_it

## Experimental changes
if [[ -n $SampShell_experimental ]]; then
	# setopt BG_NICE # <-- we don't have much of an opinion on this.
	setopt AUTO_RESUME # Single words can be used to resume commands; IDK how useful this is
	setopt LONG_LIST_JOBS # long-format; do i need this?
	setopt NOTIFY # Immediately report when jobs are done, instead of waiting. I'm not sure whether i want to wait or not, so that's why this is here.
fi

####################################################################################################
#                                              MacOS                                               #
####################################################################################################
if [[ $VENDOR != apple ]]; then
	## Add case-insensitive for tab completion
	autoload -U compinit; compinit
	zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
fi

####################################################################################################
#                                              Prompt                                              #
####################################################################################################
source ${0:P:h}/extended/prompt.zsh
alias make-ps1=make-prompt
make-prompt # Set th eprompt

####################################################################################################
#                                              Safety                                              #
####################################################################################################
## Set safety options
setopt NO_CLOBBER        # Should already be set, but just in case.
setopt CLOBBER_EMPTY     # However, you can clobber empty files.
setopt NO_RM_STAR_SILENT # In case it's accidentally unset, force `rm *` to ask for confirmation
# Note that the rest of the config for safety (eg `alias rm='rm -i`) are in `posix/interactive.sh`
