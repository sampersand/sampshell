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

####################################################################################################
#                                       Changing Directories                                       #
####################################################################################################

## Add named directories
source ${0:P:h}/helpers/named-directories.zsh
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
#                                             History                                              #
####################################################################################################

## Enables the "record-every-command" feature, which stores nearly every command for later analysis.
source ${0:P:h}/helpers/record-every-command.zsh

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
unsetopt HIST_IGNORE_ALL_DUPS # Ensure that non-contiguous duplicates are kept around.
unsetopt HIST_SAVE_NO_DUPS    # (This is just `HIST_IGNORE_ALL_DUPS` but for saving.)
unsetopt NO_APPEND_HISTORY    # Ensure we append to the history file when saving, not overwrite it.
unsetopt SHARE_HISTORY        # Don't constantly share history across interactive shells

## Enable and disable history. These also enable/disable record-every-command
function disable-history { fc -p && _SampShell_nosave_hist=1 && echo 'History saving disabled.' }
function enable-history  { fc -P && _SampShell_nosave_hist=  && echo 'History saving enabled.'  }

## Ensure we don't store enable-history or disable-history.
# Stick it before whatever `record-every-command` sets, otherwise we'll record (en|dis)able-history.
zshaddhistory_functions[1,0]=(_SampShell-nosave-enable-disable-history)
function _SampShell-nosave-enable-disable-history {
	[[ "${1%$'\n'}" != ((en|dis)able-history) ]] # Use `!=` so we return `1` in case of success
}

####################################################################################################
#                                               Jobs                                               #
####################################################################################################
	
## Setup job options (jobs programs in the background, started by eg `echo hi &`)
setopt AUTO_CONTINUE           # Always send `SIGCONT` when disowning jobs, so they run again.
unsetopt NO_MONITOR            # Enable job control, in case it's not already sent
unsetopt NO_CHECK_JOBS         # Confirm before exiting the shell if there's suspended jobs
unsetopt NO_CHECK_RUNNING_JOBS # Same as CHECK_JOBS, but also for running jobs.
unsetopt NO_HUP                # When the shell closes, send SIGHUP to all remaining jobs.

####################################################################################################
#                                            The Prompt                                            #
####################################################################################################

## Load in the prompt creator. This also sets up prompt options for us, as they're required for it.
source ${0:P:h}/helpers/prompt.zsh

## Create the prompt with default options
make-ps1

####################################################################################################
#                                        Entering Commands                                         #
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
#                                           Key Bindings                                           #
####################################################################################################
source ${0:P:h}/helpers/bindkey.zsh

####################################################################################################
#                                           Autocomplete                                           #
####################################################################################################
source ${0:P:h}/helpers/completion.zsh

####################################################################################################
#                                       Experimental Config                                        #
####################################################################################################

## Load "experimental" options---things I'm not sure yet about.
[[ -z $SampShell_no_experimental ]] && source ${0:P:h}/interactive/experimental.zsh

####################################################################################################
#                                      Functions and Aliases                                       #
####################################################################################################

## All helper functions and aliases should be defined here.
source ${0:P:h}/interactive/utils.zsh
