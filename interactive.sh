# Load the non-interactive config file in case it hasn't been loaded already.
if [ -z "$SampShell_NONINTERACTIVE_LOADED" ]; then
	. "${SampShell_HOME:-"$(dirname "$0")"}/non-interactive.sh"
fi

# Load all the shared files.
for file in "$SampShell_HOME"/shared/*; do
	. "$file"
done

# If we also have zsh, load its stuff
[ -n "$ZSH_VERSION" ] && for file in "$SampShell_HOME"/zsh/*; do
	. "$file"
done
