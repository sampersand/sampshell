# Prints out how many arguments were passed; used in testing expansion syntax.
nargs () { echo "$#"; }

alias cpu='top -o cpu'

## Deleting files
# `rm -d` is in safety.
alias purge='command rm -ridP' ## Purge deletes something entirely
ppurge () { echo "todo: parallelize purging"; }

alias pargs=prargs
prargs () {
	SampShell_scratch=0

	until [ "$#" = 0 ]; do
		SampShell_scratch=$((SampShell_scratch + 1))
		printf '%3d: %s\n' "$SampShell_scratch" "$1"
		shift
	done

	unset -v SampShell_scratch
}

ping () { curl --connect-timeout 10 ${1:-http://www.example.com}; }

export SampShell_WORDS="${SampShell_WORDS:-/usr/share/dict/words}"
[ -z "$words" ] && export words="$SampShell_WORDS" # Only set `words` if it doesnt exist

clean_sh () {
	[ -n "$TERM" ] && set -- "TERM=$TERM" "$@"
	env -i SHELL="${clean_sh_shell:-/bin/sh}" "HOME=$HOME" "$@" \
		"${clean_sh_shell:-/bin/sh}" ${clean_sh_args}
}

## Reloads all configuration files
# This is the same as `SampShell_reload` so that it's easy to replace, as
# opposed to an alias.
reload () { SampShell_reload "$@"; }

## Reloads SampShell.
# If given an argument, it `.`s `$SampShell_ROOTDIR/<arg>` and returns. If
# given no arguments, it first `.`s `$ENV` if it exists, and then will `.` all
# of SampShell (via `$SampShell_ROOTDIR/both`).
SampShell_reload () {
	if [ "$1" = -- ]; then
		shift
	elif [ "$1" = -h ] || [ "$1" = --help ]; then
		cat <<-'EOS'
		usage: SampShell_reload [--] path
		       SampShell_reload [-h/--help]

		In the first form, sources '$SampShell_ROOTDIR/<path>' and returns.
		In the second, sources '$ENV' if it exists, then '$SampShell_ROOTDIR/both'
		EOS
		return 64
	fi

	: "${SampShell_ROOTDIR:?SampShell_ROOTDIR must be supplied}"

	# If we're given an argument, then that's the only thing to reload; do that,
	# and return.
	if [ "$#" -ne 0 ]; then
		set -- "${SampShell_ROOTDIR:?}/$1"
		printf 'Reloading SampShell file: %s\n' "$1"
		. "$1"
		return
	fi

	set -- "$SampShell_ROOTDIR/both"

	# We've been given no arguments. First off, reload `$ENV` if it's present.
	if  [ -n "$ENV" ]; then
		# On the off chance that `$ENV` is `$SampShell_ROOTDIR/both`, don't reload
		# SampShell twice.
		if [ "$1" -ef "$ENV" ]; then
			echo 'Not loading $ENV; same as SampShell'
		else
			printf 'Reloading $ENV: %s\n' "$ENV"
			. "$ENV" || return
		fi
	fi

	# Now reload all of sampshell
	printf 'Reloading SampShell: %s\n' "$1"
	. "$1"
}
