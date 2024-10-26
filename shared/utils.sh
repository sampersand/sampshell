# Prints out how many arguments were passed; used in testing expansion syntax.
nargs () { echo "$#"; }

prargs () {
	SampShell_scratch=0

	until [ "$#" = 0 ]; do
		SampShell_scratch=$((SampShell_scratch + 1))
		printf "%3d: %s\n" "$SampShell_scratch" "$1"
		shift
	done

	unset -v SampShell_scratch
}

alias pargs=prargs

export SampShell_WORDS="${SampShell_WORDS:-/usr/share/dict/words}"
[ -z "$words" ] && export words="$SampShell_WORDS" # Only set `words` if it doesnt exist

clean_sh () {
	[ -z "$TERM" ] && set -- "$@" "TERM=$TERM"
	env -i SHELL=/bin/sh HOME="$HOME" "$@" /bin/sh
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
	unset -v SampShell_noninteractive_loaded

	set -- "${SampShell_ROOTDIR?}/${1:-interactive.sh}"
	. "$1" || return $?
	echo "Reloaded $1"
}

# Use the reload alias if it doesn't already exist
type reload >/dev/null 2>&1 || alias reload=SampShell_reload

# Same as `.`, except only does it if the file exists.
SampShell_source_optional () until [ "$#" = 0 ]; do
	[ -e "$1" ] && . "$1"
	shift
done

# Same as `.`, except warns if it doesn't exist.
SampShell_source_or_warn () until [ "$#" = 0 ]; do
	if [ -e "$1" ]; then
		. "$1"
	else
		echo "[WARN] Unable to source file: $1" >&2
	fi
	shift
done
