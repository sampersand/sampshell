# Load the non-interactive config file in case it hasn't been loaded already.
if [ -z "$SampShell_noninteractive_loaded" ]; then
	. "${SampShell_ROOTDIR:-"$(dirname "$0")"}/non-interactive.sh"
fi

# Load all the shared files.
for file in "$SampShell_ROOTDIR"/shared/*; do
	. "$file"
done

# If we also have zsh, load its stuff
[ -n "$ZSH_VERSION" ] && for file in "$SampShell_ROOTDIR"/zsh/*; do
	. "$file"
done
