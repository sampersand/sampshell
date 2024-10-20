# Set history argument sizes. I want them to be large so I can see them later.
HISTSIZE=1000000    # how many lines to load into history originally
SAVEHIST=1000000    # how many lines to save at the end

# `history` isn't technically valid, so only use it if it does exist.
if type history >/dev/null 2>&1; then
	alias h=history
else
	alias h='fc -l'
fi

