### This file is for setting up "named directories" in zsh, a-la `cd ~foo`

## Add a directory to the list of named directories.
function add-named-dir {
	local dir name

	# Extract the name and directory from the arguments
	case $# in
	1) dir=$1; name=${dir:t} ;;
	2) dir=$2; name=$1 ;;
	*)
		print >&2 "usage: $0 [name] dir"
		print >&2
		print >&2 'Lets you use ~name as a shorthand for `dir`, eg `cd ~name/bar/baz`'
		print >&2 'If `name` is not given, it defaults to the last part of `dir`'
		return 1
	esac

	# Ensure a directory and name are actually given
	if [[ -z $dir ]] then
		print >&2 -r -- "$0: an empty directory was given"
		return 1
	elif [[ -z $name ]] then
		print >&2 -r -- "$0: an empty name was given"
		return 1
	fi

	builtin hash -d -- $name=$dir
}

## Remove a directory from the list of directories.
function del-named-dir {
	if (( $# != 1 )) then
		print >&2 -r "usage: $0 name"
		print >&2
		print >&2 -r "removes 'name' as a named dir"
		return 1
	fi

 	# NOTE: the `:t` is so you can pass paths in, as `/` is an invalid char
 	# in named directories. Also, provides parity with `add-named-dir`
	builtin unhash -d -- ${1:t}
}
