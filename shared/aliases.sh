alias f='find .'
alias t=trash
alias s=subl
alias ss=ssubl
alias '%= ' # Make sure an `%` at the beginning of a line will be ignored.

alias cpu='top -o cpu'

## Spellcheck
alias gti=git
alias sbul=subl
alias ssbul=ssubl

## Listing files
alias ls='ls -AFq' # Always print out `.` files, and for longform, human-readable sizes, and colours
alias ll='ls -l'    # Shorthand for `ls -al`

## Deleting files
# `rm -d` is in safety.
alias purge='echo command rm -ridP' ## Purge deletes something entirely
ppurge () { echo "todo: parallelize purging"; }
