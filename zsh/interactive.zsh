## TODO: Maybe also have a `.zprofile`?

# TODO: can you autoload multiple times? if so stick this in individual files, eg macos.zsh
autoload -U compinit; compinit

## Load in all the setup that's in separate files.
for file in ${0:P:h}/interactive/*.zsh; do
	source $file
done


## Add commonly-used aliases
[[ $VENDOR != apple ]] && eval "$(alias -L ls)hGb" # add more options to `ls` which I know macOS supports
alias '%= ' '$= ' # `$` or `%` alone at he start of a line is ignored; lets you paste commands in.
alias d=dirs
alias clsh=clean-shell


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
exit

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
setopt EQUALS
function clean-sh { clean-shell --shell =sh $@ }
function clean-zsh { clean-shell --shell =zsh $@ }
SampShell_command_exists dash && function clean-dash { clean-shell --shell =dash $@ }

####################################################################################################
#                                              TODOS                                               #
####################################################################################################

. ${0:P:h}/scripting-or-interactive.zsh
# TODO: `CLOBBER_EMPTY` with `mv-safe` and defaults?

## Default options that really should be enabled. TODO: should i always set these?
if true || [[ -n $SampShell_set_defaults_i_want_set ]]; then
	setopt UNSET # allow variables to be empty
	setopt BANG_HIST # do `!`-style history expansion
	setopt ALIASES # I use them
	setopt NO_IGNORE_EOF #  use ctrl+d a lot
	setopt NO_RM_STAR_SILENT # make sure to ask for `rm *`
	setopt CHECK_{,RUNNING_}JOBS # DEFUALT; make sure we dont exit with stuff
	setopt PROMPT_SP # print `%` on non-full lines
fi

## 16.2.1 Changing Directories
setopt AUTO_CD # cd to directories without using `cd`
setopt AUTO_PUSHD # always push dirs onto the stack
setopt CDABLE_VARS # able to CD to variables
setopt CHASE_LINKS # Ensure we always resolve symlinks to their real value when cding
setopt PUSHD_IGNORE_DUPS # dont put multiple copies onto the dir stack.

## 16.2.2 Completion
echo 'todo: completion'

## 16.2.3 Expansion and Globbing
setopt MAGIC_EQUAL_SUBST # Any arguments in the form `foo=expr` does `~`/`=` expansion on expr

## 16.2.4 History
[[ -n $SampShell_experimental ]] && setopt EXTENDED_HISTORY # store thigns in extended history
setopt HIST_ALLOW_CLOBBER # Add `|` to history entries, so you can clobber things
echo 'todo: more histories'
setopt HIST_IGNORE_SPACE # don't keep spaces
setopt HIST_NO_STORE # don't store history commands
setopt histreduceblanks

## 16.2.6 Input/Output
setopt CORRECT # Correct commands!
setopt INTERACTIVE_COMMENTS # Suuuper useful, I do this all the time.

## 16.2.9 Scripts and Functions
setopt MULTI_FUNC_DEF # unset what's in `env.zsh`, as i do this enough on the cmd line

## 16.2.12 Zle
echo 'todo: ZLE'
# setopt HIST_FIND_NO_DUPS; par tof line editor

## Variables
DIRSTACKSIZE=30 # If it goes above this it's kinda hard to see.
histchars[2]=, # as `^` is too far away lol
REPORTTIME=3 # Report the time of commands that take more than N seconds

# emulate sh -c '. "${(e)ENV}"'
