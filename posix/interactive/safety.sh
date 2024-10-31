# Don't clobber files with `>`; must use `>|`
set -o noclobber

# Override builtins with safer versions.

alias rm='rm-safe'
alias mv='mv -i'
alias cp='cp -i'

# Still let you do the builtins
alias rmm='rm -f'
alias mvv='mv -f'
alias cpp='cp -f'
