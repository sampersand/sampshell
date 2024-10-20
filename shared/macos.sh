if type pbcopy >/dev/null 2>&1; then
	# Same as `pbcopy` but will copy its arguments to the pastebin if given.
	pbc () if [[ $# = 0 ]]; then
		pbcopy
	else
		echo "$*" | pbcopy
	fi

	# Pastes the pasteboard
	alias pbp=pbpaste
fi

echo 'todo: caffeinate'
