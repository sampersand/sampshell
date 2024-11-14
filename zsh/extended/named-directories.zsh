### This file is for setting up "named directories" in zsh, a-la `cd ~ss`
# Note that this file doesn't actually add any named dirs itself, but just adds the functions.

# By default pass `-v` to `dirs`, unless any other arguments are given.
function dirs {
	builtin dirs ${@:--v} 
}

## Add a directory to the list of named directories.
function add-named-dir {
	local dir name

	if [[ $1 = -- && $# -le 3 ]]; then
		shift
	elif [[ $1 = -h || $1 = --help || $# -gt 2 ]]; then
		# the `$((...))` is to print to stderr, and return 1, if bad args are given.
		cat <<EOS >&$(($# > 2 ? 2 : 1))
usage: $0 [--] [name=basename dir] dir
       $0 [--] [dir=PWD]
Adds 'name' as a named dir, so you can 'cd ~name' and it goes to 'dir'. If only
one argument is given, the name is the basename of the PWD
EOS
		return $(($# > 2 ? 1 : 0))
	fi

	if [[ $# = 2 ]]; then
		dir=$2
		name=$1
	else
		dir=${1:-$PWD}
		name=${dir:t}
	fi

	if [[ -z $name ]]; then
		printf '%s: a name must be supplied (dir=%q)\n' $0 $dir >&2
		return 1
	elif [[ -z $dir ]]; then
		SampShell_log '[WARN] %s: named dir "%s" points to an empty dir, which defaults to $HOME' \
			$0 $name
	elif [[ ! -d $dir ]]; then
		SampShell_log '[WARN] %s: named dir "%s" points to a non-directory: %q' $0 $name $dir
	fi

	builtin hash -d -- $name=$dir
}

## Remove a directory from the list of directories.
function del-named-dir {
	if [[ $1 = -- && $# -le 2 ]]; then
		shift
	elif [[ $1 = -h || $1 = --help || $# -gt 1 ]]; then
		# the `$((...))` is to print to stderr, and return 1, if bad args are given.
		cat <<EOS >&$(($# > 1 ? 2 : 1))
usage: $0 [--] [name=basename \$PWD]
removes 'name' as a named dir.
EOS
		return $(($# > 1 ? 1 : 0))
	fi


	builtin unhash -d -- ${1:-${PWD:t}}
}
