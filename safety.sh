# Don't clobber files with `>`; must use `>|`
set -o noclobber

## Override builtins with safer versions
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# Still let you do the builtins
alias rrm='command rm'
alias mmv='command mv'
alias ccp='command cp'

if [ "$ZSH_VERSION" ]; then
	setopt NO_CLOBBER    # Cannot use `>` to overwrite files; `>!`/`>|` needed.
	setopt CLOBBER_EMPTY # However, you can clobber empty files.
	setopt RM_STAR_WAIT  # Accidentally do `rm *`, wait 10s before doing it.
fi
