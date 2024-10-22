# Prints out how many arguments were passed; used in testing expansion syntax.
nargs () {
	echo $#;
}

prargs () (
	i=0 # lol local variables inside a subshell
	for arg; do
		printf "%-3d %s\n" "$i" "$arg"
		i=$((i + 1))
	done
)

export SampShell_WORDS="${SampShell_WORDS:-/usr/share/dict/words}"
[ -z "$words" ] && export words="$SampShell_WORDS" # Only set `words` if it doesnt exist

clean_sh () {
	set -- 'SHELL=/bin/sh' "$@"
	[ -z "$TERM" ] && set -- "$@" "TERM=$TERM"
	env -i "$@" /bin/sh
}

SampShell_reload () {
	if [ "$1" = '--' ]; then
		shift
	elif [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
		echo "usage: $0 [--] [file=interactive.sh]"
		echo '        Reloads samp shell. $SampShell_ROOTDIR should be set.'
		return 255
	fi

	# Make sure it's not set regardless of what we're loading.
	unset SampShell_noninteractive_loaded

	set -- "${SampShell_ROOTDIR?}/${1:-interactive.sh}"
	. "$1" || return $?
	echo "Reloaded $1"
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
