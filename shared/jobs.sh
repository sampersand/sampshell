alias j=jobs
alias k+='kill %+'

## Parallelize a function by making a new job once per argument given
function parallelize_it () {
	local fn="$1"
	shift

	if [ "$1" = '--' ]; then
		shift
	elif [ "$1" = '-h' ] || [ "$1" = '--help' ] || [ -z "$fn" ]; then
		echo "usage: $0 fn [--] [args ...]"
		echo $'\t'"This command executes 'fn' once for each arg as background job"
		return -1
	fi

	for arg; do
		"$fn" "$arg" &
	done
}


: "${SampShell_paralleize_it_skip_string:=x}"
function parallelize_it_skip () {
	local fn="$1"
	shift

	if [ "$1" = '--' ]; then
		shift
	elif [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
		echo "usage: $0 fn [--] [args ...]"
		echo $'\t'"This command executes 'fn' once for each arg as background job"
		echo $'\tIf an arg is $SampShell_paralleize_it_skip_string ('"$SampShell_paralleize_it_skip_string"'), neither it nor the previous arg will'
		echo $'\tbe executed. A special case is if $SampShell_paralleize_it_skip_string is the first arg, it'
		echo $'\twill also be executed.'
		return -1
	fi

	: "${fn?a function must be supplied}"

	until [ $# = 0 ]; do
		if [ "$2" == "$SampShell_paralleize_it_skip_string" ]; then
			shift
		else
			"$fn" "$1" &
		fi

		shift
	done
}

echo 'Todo: set -m'
