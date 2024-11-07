# Shorthands
alias s=subl
alias '%= ' # Let you paste prompts in; zsh lets you alias `$` too.
alias ss=ssubl
alias ssubl='subl --create'
alias cpu='top -o cpu'

## Spellcheck
alias gti=git
alias sbul=subl
alias ssbul=ssubl

## Listing files
alias ls='ls -AFq' # Always print out `.` files, and for longform, human-readable sizes, and colours
alias ll='ls -l'   # Shorthand for `ls -al`

## Deleting files
# `rm -d` is in safety.
alias purge='command rm -ridP' ## Purge deletes something entirely
ppurge () { echo "todo: parallelize purging"; }
