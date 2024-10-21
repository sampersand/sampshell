# Set history argument sizes. I want them to be large so I can see them later.
HISTSIZE=1000000    # how many lines to load into history originally
SAVEHIST=1000000    # how many lines to save at the end

echo 'todo: HISTFILE!'

## Sets up `history` and `h` aliases
if ! type history >/dev/null 2>&1; then
	alias history='fc -l'
fi

alias h=history
