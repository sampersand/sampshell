## Setup Sublime Text commands, unless it's disabled.
if [ -z "${SampShell_no_subl-}" ]  ; then
	alias s=subl
	alias ss=ssubl
	alias ssubl='subl --create'

	## Spellchecks
	alias sbul=subl
	alias ssbul=ssubl
fi

## Listing files
alias ls='ls -AFq' # Always print out `.` files, and for longform, human-readable sizes, and colours
alias ll='ls -l'   # Shorthand for `ls -al`

## Misc
alias '%= ' # Let you paste prompts in; zsh lets you alias `$` too.

alias parallelize_it=SampShell_parallelize_it
alias cdd=SampShell_cdd
