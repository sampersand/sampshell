if command -V pbcopy >/dev/null 2>&1; then
	# Same as `pbcopy` but will copy its arguments to the pastebin if given.
	pbcopy () {
		if [ "$#" = 0 ]; then
			command pbcopy
		else
			echo "$*" | command pbcopy
		fi
	}

	# Shorthand aliases
	pbcc () { "$@" | pbcopy; } # `pbcopy` execpt it runs a command
	alias pbc=pbcopy
	alias pbp=pbpaste
fi

echo 'todo: caffeinate'
