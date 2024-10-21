# Prints out how many arguments were passed; used in testing expansion syntax.
nargs () { echo $#; }

export SampShell_WORDS="${SampShell_WORDS:-/usr/share/dict/words}"
[ -z "$words" ] && export words="$SampShell_WORDS" # Only set `words` if it doesnt exist

SampShell_reload () {
	if [ "$1" = '--' ]; then
		shift
	elif [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
		echo "usage: $0 [--] [file=interactive.sh]"
		echo $'\tReloads samp shell. $SampShell_ROOTDIR should be set.'
		return -1
	fi

	# Make sure it's not set regardless of what we're loading.
	unset SampShell_noninteractive_loaded

	local file_to_reload="${SampShell_ROOTDIR?}/${1:-interactive.sh}"
	. "$file_to_reload" || return $?
	echo "Reloaded $file_to_reload"
}

# Use the reload alias if it doesn't already exist
type reload >/dev/null 2>&1 || alias reload=SampShell_reload

# Same as `source`, except only does it if the file exists.
source_optional () for file; do
	[ -e "$file" ] && . "$file"
done

# Same as `source`, except warns if it doesn't exist.
source_or_warn () for file; do
	if [ -e "$file" ]; then
		. "$file"
	else
		echo "[WARN] Unable to source file: $file" >&2
	fi
done
