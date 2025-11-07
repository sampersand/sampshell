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

alias gdno='__deprecated git diff --name-only'
gdh () {
	__deprecated
	[ "$#" = 0 ] && set -- 'HEAD~1'
	git diff "$@"
}
gdd () {
	__deprecated
	[ "$#" = 0 ] && set -- 'HEAD~1'
	git diff --name-status "$@"
}
alias gdol='__deprecated gdd'
# alias gddm='gdd "$(git-master-branch)"'
