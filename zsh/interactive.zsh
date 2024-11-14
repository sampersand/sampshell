#### Basic SampShell definitions for interactive ZSH shell instances.


# Load "experimental" options---things I'm not sure yet about
[[ -n $SampShell_experimental ]] && source ${0:P:h}/experimental.zsh

####################################################################################################
#                                      Functions and Aliases                                       #
####################################################################################################

[[ $VENDOR == apple ]] && eval "${$(alias -L ls)/ls/l}hGb" # add the `l` alias more options to `ls` which I know macOS supports
alias '%= ' '$= ' # Let's you paste commands in; a start `$` or `%` on its own is ignored.
alias d=dirs
alias mk=mkdir
alias parallelize-it=parallelize_it ## Create the shorthand for `parallelize-it`; TODO: do we stillw ant that

# Reloads the shell by rerunning all the ~/.zxxx` scripts.
# TODO: should we also load in the system config?
function reload {
	for file in ${ZDOTDIR:-$HOME}/.z{shenv,profile,shrc,login}; do
		SampShell_dot_if_exists $file
	done
}

## Git shorthand, make `@-X` be the same as `@{-X}`. this has to be in an anonymous function, else
# `i` will leak.
() {
	local i
	for (( i = 0; i < 10; i++ )); do
		alias -g "@-$i=@{-$i}"
	done
}

## Adds in "clean shell" functions, and the clsh alias
function clean-sh   { clean-shell --shell =sh $@ } # use which in case EQUALS is unset,
function clean-zsh  { clean-shell --shell =zsh $@ } # even though it's set by default.
function clean-bash { clean-shell --shell =bash $@ }
SampShell_command_exists dash && function clean-dash { clean-shell --shell =dash $@ }
alias clsh=clean-shell
function clzsh { clean-zsh --none -- -fd $@ } # Don't set SampShell variables, only $TERM/$HOME,etc

# Removedir and mkdir aliases. Only removes directories with `.DS_Store` in them
rd () { builtin rm -f -- ${1:?need a dir}/.DS_Store && builtin rmdir -- $1 }
md () { builtin mkdir -p -- "${1:?missing a directory}" && builtin cd -- "$1" }


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
HISTSIZE=1000000   # Keep a lot so it's easy to refernece
SAVEHIST=$HISTSIZE # How many lines to save at the end

## History options
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

## Enable and disable history
function disable-history { fc -p && SampShell_nosave_hist=1 && echo 'History saving disabled.' }
function enable-history  { fc -P && SampShell_nosave_hist=  && echo 'History saving enabled.'  }

## Don't store enable-history or disable-history
zshaddhistory_functions[1,0]=(SampShell-nosave-enable-disable-history) # Put before record-every-command
function SampShell-nosave-enable-disable-history { [[ "${1%$'\n'}" != ((en|dis)able-history) ]] }

####################################################################################################
#                                        Entering Commands                                         #
####################################################################################################

## Set the prompt
source ${0:P:h}/extended/prompt.zsh
make-prompt # Set the prompt, which `prompt.zsh` doesn't do for us by default.

## Set interactive options
setopt INTERACTIVE_COMMENTS # Enable comments in interactive shells; I use this all the time
setopt RC_QUOTES            # Within `'` strings, `''` is interpreted as an escaped `'`.
setopt MAGIC_EQUAL_SUBST    # Supplying `a=b` on the command line does `~`/`=` expansion
setopt BANG_HIST            # Lets you do `!!` and friends
setopt NO_CLOBBER           # (`posix/interactive.sh` should've set it) Disables clobbering files.
setopt CLOBBER_EMPTY        # With `NOCLOBBER`, this Lets you clobber empty files
unsetopt RM_STAR_SILENT     # In case it's accidentally unset, force `rm *` to ask for confirmation
# setopt AUTO_RESUME        # Like `AUTO_CD`, except for jobs. IDK how useful it is.
unsetopt GLOB_SUBST         # (unset is default) When set, requires quoting everything like bash.

## Update variables ZSH uses in interactive mode.
histchars[2]=,      # Change from `^ehco^echo` to `,ehco,echo`; `^` is just so far away lol
: "${REPORTTIME=4}" # Print the duration of commands that take more than 4s of CPU time
# DIRSTACKSIZE=30   # I just started using dirstack more, if it ever grows unwieldy I can set this.

## Zstyles; this might be its own category if I get more into zstyle.
autoload -U compinit; compinit
if [[ $VENDOR = apple ]]; then
	zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case-insensitive for tab completion
fi

####################################################################################################
#                                               Jobs                                               #
####################################################################################################
## Enable options. Note the `CHECK_XXX_JOBS` options could technically be in safety.zsh
setopt MONITOR            # Enable job control, in case it's not already sent
setopt AUTO_CONTINUE      # Always send `SIGCONT` when disowning jobs, so they run again.
setopt CHECK_JOBS         # Confirm before exiting the shell if there's suspended jobs
setopt CHECK_RUNNING_JOBS # Same as CHECK_JOBS, but also for running jobs.
setopt HUP                # When the shell closes, send SIGUP to all jobs.
# setopt LONG_LIST_JOBS   # This only prints out the PID too, which I don't find too helpful.
# unsetopt BG_NICE        # When set (the default), all bg jobs are run at lower priority. IDK how useful this is, as i dont use job control a lot
