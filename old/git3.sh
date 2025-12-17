alias ig='git ignore'
alias gdb='git branch --delete'
alias gbmv='git branch --move'
alias gbrmv='git branch --move'
alias gam='git commit --amend'
alias gammend='git commit --amend'

gdd () {
	[ "$#" = 0 ] && set -- 'HEAD~1'
	git diff --name-status "$@"
}
alias gdol='__deprecated gdd'
