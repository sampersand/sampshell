if SampShell_command_exists pbcopy; then
	# Same as `pbcopy` but will copy its arguments to the pastebin if given.
	pbc () {
		if [ "$#" = 0 ]; then
			command pbcopy
		else
			echo "$*" | command pbcopy
		fi
	}

	# Shorthand aliases
	pbcc () { "$@" | pbcopy; } # `pbcopy` execpt it runs a command
	alias pbp=pbpaste
fi

[ -n "${SampShell_print_todos-}" ] && echo 'todo: caffeinate'
