# Load the non-interactive one in case it hasn't been loaded already.
. "${SampShell_HOME:-"$HOME/.sampshell"}/non-interactive.sh"

# Load all the shared files.
for file in "$SampShell_HOME"/shared/*; do
	. "$file"
done

# If we also have zsh, load its stuff
[ -n "$ZSH_VERSION" ] && for file in "$SampShell_HOME"/zsh/*; do
	. "$file"
done
