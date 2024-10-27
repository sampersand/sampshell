# set -f 

# Load the non-interactive config file in case it hasn't been loaded already.
if [ -z "$SampShell_POSIX_noninteractive_loaded" ]; then
	. "${SampShell_ROOTDIR:-"$(dirname "$0")"}/posix/non-interactive.sh"
fi

# Load all the shared files.
for file in "$SampShell_ROOTDIR"/posix/interactive/*; do
	. "$file"
done

