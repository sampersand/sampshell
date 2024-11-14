
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
# echo 'todo: completion'

## 16.2.3 Expansion and Globbing
setopt MAGIC_EQUAL_SUBST # Any arguments in the form `foo=expr` does `~`/`=` expansion on expr

## 16.2.6 Input/Output
setopt CORRECT # Correct commands!
setopt INTERACTIVE_COMMENTS # Suuuper useful, I do this all the time.

## 16.2.9 Scripts and Functions
setopt MULTI_FUNC_DEF # unset what's in `env.zsh`, as i do this enough on the cmd line

## 16.2.12 Zle
# echo 'todo: ZLE'
# setopt HIST_FIND_NO_DUPS; par tof line editor

## Variables
DIRSTACKSIZE=30 # If it goes above this it's kinda hard to see.
histchars[2]=, # as `^` is too far away lol
REPORTTIME=3 # Report the time of commands that take more than N seconds

# emulate sh -c '. "${(e)ENV}"'
