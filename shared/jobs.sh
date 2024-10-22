set -m
alias j=jobs
alias k+='kill %+'

## Parallelize a function by making a new job once per argument given
parallelize_it () {
	local fn="$1"
	shift

	if [ "$1" = '--' ]; then
		shift
	elif [ "$1" = '-h' ] || [ "$1" = '--help' ] || [ -z "$fn" ]; then
		echo "usage: $0 fn [--] [args ...]"
		echo "        This command executes 'fn' once for each arg as background job"
		return 255
	fi

	for arg; do
		"$fn" "$arg" &
	done
}


: "${SampShell_paralleize_it_skip_string:=x}"
parallelize_it_skip () {
	local fn="$1"
	shift

	if [ "$1" = '--' ]; then
		shift
	elif [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
		echo "usage: $0 fn [--] [args ...]"
		echo "        This command executes 'fn' once for each arg as background job"
		echo '        If an arg is $SampShell_paralleize_it_skip_string ('"$SampShell_paralleize_it_skip_string"'), neither it nor the previous arg will'
		echo '        be executed. A special case is if $SampShell_paralleize_it_skip_string is the first arg, it'
		echo '        will also be executed.'
		return 255
	fi

	: "${fn?a function must be supplied}"

	until [ $# = 0 ]; do
		if [ "$2" = "$SampShell_paralleize_it_skip_string" ]; then
			shift
		else
			"$fn" "$1" &
		fi

		shift
	done
}

echo 'todo: set -m'
