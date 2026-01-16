function __deprecated () {
	print -P "\n%F{red}\tfunction ${(qq)1:-$funcstack[2]} is deprecated! don't use it!%f\n" >&2
	if (( $# )) "$@"
}

################################################################################
#                           Deprecated git commands                            #
################################################################################

gclear () {
	__deprecated
	# git add --all && git stash push && git status
	echo 'todo'
	return 1
}
