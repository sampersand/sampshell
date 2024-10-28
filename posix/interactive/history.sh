# Make sure `fc` is even around.
command -V fc >/dev/null 2>&1 || return 0

# Set history argument sizes. I want them to be large so I can see them later.
HISTSIZE=1000000 # how many lines to load into history originally

# Set HISTFILE if it doesn't exist.
: "${HISTFILE="${SampShell_HISTDIR:-"${HOME}"}/.sampshell_history"}"

# Sets up `history` and `h` aliases
if ! command -V history >/dev/null 2>&1; then
	alias history='fc -l'
fi

alias h=history
