## Outline

. ${0:P:h}/all.zsh
return

## Load in all the setup that's in separate files.
for file in ${0:P:h}/interactive/*.zsh; do
	source $file
done


## Add commonly-used aliases
[[ $VENDOR == apple ]] && eval "${$(alias -L ls)/ls/l}hGb" # add the `l` alias more options to `ls` which I know macOS supports
alias '%= ' '$= ' # `$` or `%` alone at he start of a line is ignored; lets you paste commands in.
alias d=dirs
alias mk=mkdir


### Add named directories
[[ -n $SampShell_ROOTDIR ]] && add-named-dir ss $SampShell_ROOTDIR
[[ -n $SampShell_TMPDIR ]] && add-named-dir tmp $SampShell_TMPDIR
[[ -n $SampShell_TRASHDIR ]] && add-named-dir trash $SampShell_TRASHDIR
[[ -d ~/Desktop ]] && add-named-dir d ~/Desktop
[[ -d ~/Downloads ]] && add-named-dir dl ~/Downloads

####################################################################################################
#                                             History                                              #
####################################################################################################

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


## "Record every command"
source ${0:P:h}/interactive/record-every-command.zsh

# Enable and disable history
function disable-history { fc -p && SampShell_nosave_hist=1 && echo 'History saving disabled.' }
function enable-history { fc -P && SampShell_nosave_hist= && echo 'History saving enabled.' }

# Don't store enable-history or disable-history
zshaddhistory_functions[1,0]=(SampShell-nosave-enable-disable-history) # Put before record-every-command
function SampShell-nosave-enable-disable-history { [[ "${1%$'\n'}" != ((en|dis)able-history) ]] }

####################################################################################################
#                                            Functions                                             #
####################################################################################################

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

####################################################################################################
#                                              TODOS                                               #
####################################################################################################

. ${0:P:h}/interactive-todos.zsh
