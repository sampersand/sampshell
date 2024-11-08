# Don't clobber files with `>`; must use `>|`
set -o noclobber

# Override builtins with safer versions.
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

## Shorthand aliases for the "safer" options
alias r=trash
alias m=mv-safe

# Still let you do the builtins
alias rmm='rm -f'
alias mvv='mv -f'
alias cpp='cp -f'
