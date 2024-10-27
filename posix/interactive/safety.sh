# Don't clobber files with `>`; must use `>|`
set -o noclobber

# Override builtins with safer versions.

# `rm`, except safer:
#   For every argument given on the command line, if it refers to an
#   a file or directory, prompt for deletion. However, if it's empty,
#   just go ahead and delete it without asking.
#
#   If the first argument starts with `-` (and isn't `--`), then forward
#   all the arguments to the `rm` command and don't do any custom logic.
rm () {
	# If the first argument is a `--`, then just delete that and interpret the rest
	# as filenames to delete.
	if [ "$1" = -- ]; then
		shift

	# If no arguments are given, or the first one is `-h` or `--help`, print usage.
	elif [ "$#" -eq 0 ] || [ "$1" = -h ] || [ "$1" = --help ]; then
		echo "usage: $0 [--] <files>" >&2
		echo "       $0 -(any non-dash char) --> forward to rm" >&2
		return 64

	# If the first argument starts with a `-`, then just forward to the builtin `rm`.
	elif [ "${1#-}" != "$1" ]; then
		# The first character is a `-`, then forward to the builtin rm
		command rm "$@"
		return

	fi

	# Keep track of the last non-zero exit status
	SampShell_rm_exit_status=0

	until [ "$#" -eq 0 ]; do
		# If it's an empty file, just delete it.
		if [ -f "$1" ] && [ ! -s "$1" ]; then
			command rm -- "$1"

		# If it's an empty directory, also just delete it.
		# (the `ls` lists out all non-`.`/`..` files, quotes them, then grep checks to see if there's
		elif [ -d "$1" ] && ! ls -A1q -- "$1" | grep -q .; then
			command rm -d -- "$1"

		# Otherwise call `rm` with `-i`.
		else
			command rm -i -- "$1"

		# If any of the previous things failed, set `SampShell_rm_exit_status` to that status.
		fi || SampShell_rm_exit_status=$?

		shift
	done

	set -- "$SampShell_rm_exit_status"
	unset -v SampShell_rm_exit_status # clean up!
	return "$1"
}

alias mv='mv -i'
alias cp='cp -i'

# Still let you do the builtins
alias rmm='rm -f'
alias mvv='mv -f'
alias cpp='cp -f'
