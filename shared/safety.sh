# Don't clobber files with `>`; must use `>|`
set -o noclobber

# Override builtins with safer versions
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# Still let you do the builtins
alias rrm='command rm'
alias mmv='command mv'
alias ccp='command cp'
