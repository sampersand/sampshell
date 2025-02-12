## Stuff in `.zshrc` which I used to have set, but don't need anympore
unsetopt NO_MONITOR            # Enable job control, in case it's not already sent

# I never end up doing this, so no need to set it up
setopt AUTO_CD # Enables `dir` to be shorthand for `cd dir` if `dir` isn't a valid cmd

# Experimental, see if I actually need this.
setopt PUSHD_IGNORE_DUPS # Delete duplicate entries on the dir stack when adding new ones.

# I don't find myself doing this _that_ often, and it makes `>|/dev/null` which is weird.
setopt HIST_ALLOW_CLOBBER   # Add `|` to `>` and `>>`, so that re-running the command can clobber.
