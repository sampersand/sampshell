#### Basic SampShell definitions for interactive ZSH shell instances.

# Load "experimental" options---things I'm not sure yet about
[[ -n $SampShell_experimental ]] && source ${0:P:h}/experimental.zsh

####################################################################################################
#                                        Universal Options                                         #
####################################################################################################

## Options that should always be set. 
setopt EXTENDED_GLOB   # Always have extended globs enabled, without needing to set it.
setopt GLOB_STAR_SHORT # Enable the `**.c` shorthand for `**/*.c`

####################################################################################################
#                                       Changing Directories                                       #
####################################################################################################

## Add named directories
source ${0:P:h}/extended/named-directories.zsh
[[ -n $SampShell_ROOTDIR  ]] && add-named-dir ss    $SampShell_ROOTDIR
[[ -n $SampShell_TMPDIR   ]] && add-named-dir tmp   $SampShell_TMPDIR
[[ -n $SampShell_TRASHDIR ]] && add-named-dir trash $SampShell_TRASHDIR
[[ -d ~/Desktop           ]] && add-named-dir d     ~/Desktop
[[ -d ~/Downloads         ]] && add-named-dir dl    ~/Downloads

## Default `dirs` to `dirs -v`; passing in any argument disables this.
function dirs { builtin dirs ${@:--v} }

## Add `cd` options
setopt AUTO_CD           # `foo` is the same as `cd foo` if `foo` isn't a command
setopt CDABLE_VARS       # `cd var` is a shorthand for `cd $var` and `cd ~var`
setopt AUTO_PUSHD        # Have `cd` push directories onto the directory stack
setopt PUSHD_IGNORE_DUPS # Delete duplicate entries on the cd stack.
setopt CHASE_LINKS       # Ensure we always resolve symlinks to their real value when cding

####################################################################################################
#                                             History                                              #
####################################################################################################
source ${0:P:h}/extended/record-every-command.zsh

## `HISTFILE` is already set by POSIX-compliant stuff.
HISTSIZE=1000000                # Keep a lot so it's easy to refernece
SAVEHIST=$HISTSIZE              # How many lines to save at the end
# HISTORY_IGNORE='(cmd1|cmd2*)' # Disable storing history for anything that matches the pattern.

## History options
setopt HIST_FCNTL_LOCK        # Use `fcntl` to lock files. (Supported by all modern computers.)
setopt HIST_REDUCE_BLANKS     # Remove extra whitespace between arguments
setopt HIST_ALLOW_CLOBBER     # Add `|` to `>` and `>>`, so that re-running the command can clobber.
setopt HIST_NO_STORE          # Don't store the `history` command, or `fc -l`.
setopt HIST_IGNORE_SPACE      # Don't store commands that start with a space.
setopt HIST_IGNORE_DUPS       # Don't commands that are duplicates of the immediately preceding one.
setopt HIST_EXPIRE_DUPS_FIRST # When trimming, delete duplicates commands first, then uniques.
setopt EXTENDED_HISTORY       # When saving, write the start time and duration as well; not really require
unsetopt HIST_IGNORE_ALL_DUPS # In case it's set; I like having non-contiguous dups
unsetopt HIST_SAVE_NO_DUPS    # In case it's set; This is just HIST_IGNORE_ALL_DUPS but for saving.
unsetopt NO_APPEND_HISTORY    # Ensure we append to the history file when saving, not overwrite it.
unsetopt SHARE_HISTORY        # Don't constantly share history across interactive shells

## Enable and disable history
function disable-history { fc -p && _SampShell_nosave_hist=1 && echo 'History saving disabled.' }
function enable-history  { fc -P && _SampShell_nosave_hist=  && echo 'History saving enabled.'  }

## Don't store enable-history or disable-history
zshaddhistory_functions[1,0]=(_SampShell-nosave-enable-disable-history) # Put before record-every-command
function _SampShell-nosave-enable-disable-history {
	[[ "${1%$'\n'}" != ((en|dis)able-history) ]] # Use `!=` so we return `1` in case of success
}

####################################################################################################
#                                        Entering Commands                                         #
####################################################################################################

## Set the prompt
source ${0:P:h}/extended/prompt.zsh
alias make-ps1=make-prompt
make-prompt # Set the prompt, which `prompt.zsh` doesn't do for us by default.

## Set interactive options
setopt INTERACTIVE_COMMENTS # Enable comments in interactive shells; I use this all the time
setopt RC_QUOTES            # Within `'` strings, `''` is interpreted as an escaped `'`.
setopt MAGIC_EQUAL_SUBST    # Supplying `a=b` on the command line does `~`/`=` expansion
setopt CLOBBER_EMPTY        # With `NO_CLOBBER`, this Lets you clobber empty files
setopt NO_CLOBBER           # (`posix/interactive.sh` should've set it) Disables clobbering files.
setopt NO_FLOW_CONTROL      # Modern terminals dont need control flow lol
unsetopt RM_STAR_SILENT     # In case it's accidentally unset, force `rm *` to ask for confirmation
unsetopt GLOB_SUBST         # (unset is default) When set, requires quoting everything like bash.
unsetopt NO_SHORT_LOOPS     # Allow short-forms of commands
unsetopt NO_BANG_HIST       # Lets you do `!!` and friends
[[ -n $SampShell_experimental ]] && setopt COMPLETE_IN_WORD


## Update variables ZSH uses in interactive mode.
histchars[2]=,      # Change from `^ehco^echo` to `,ehco,echo`; `^` is just so far away lol
: "${REPORTTIME=4}" # Print the duration of commands that take more than 4s of CPU time
# DIRSTACKSIZE=30   # I just started using dirstack more, if it ever grows unwieldy I can set this.

## Zstyles; this might be its own category if I get more into zstyle.
source ${0:P:h}/extended/completion.zsh

## ZLE; this might be its own category if i get more int o ZLE
source ${0:P:h}/extended/bindkey.zsh
# WORDCHARS=$WORDCHARS # ooo, you can modify which chars are for a word in ZLE

####################################################################################################
#                                               Jobs                                               #
####################################################################################################
## Enable options. Note the `CHECK_XXX_JOBS` options could technically be in safety.zsh
setopt MONITOR                 # Enable job control, in case it's not already sent
setopt AUTO_CONTINUE           # Always send `SIGCONT` when disowning jobs, so they run again.
unsetopt NO_CHECK_JOBS         # Confirm before exiting the shell if there's suspended jobs
unsetopt NO_CHECK_RUNNING_JOBS # Same as CHECK_JOBS, but also for running jobs.
unsetopt NO_HUP                # When the shell closes, send SIGUP to all jobs.

####################################################################################################
#                                      Functions and Aliases                                       #
####################################################################################################
. ${0:P:h}/interactive/utils.zsh
