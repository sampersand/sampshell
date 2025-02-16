## TODO: This file was originally 100%` sh-compliant, so now we should clean that up and make it more
# zsh-like.

## Git shorthand, make `@-X` be the same as `@{-X}`. this has to be in an anonymous function, else
# the var will leak
() while (( $# )) do
	alias -g "@-$1=@{-$1}"
	shift
done $(seq 0 10)

alias g=git

## Spellcheck
alias gti=git

ignore () {
	if [ "$#" -eq 0 ]; then
		printf >&2 'usage: ignore file [...]. Used to add files to gitignore'
		return 1
	fi

	while [ "$#" -ne 0 ]; do
		mv "$1" "$1.ignore"
		shift
	done
}
alias ig=ignore
alias gignore=ignore

: "${SampShell_git_default_master_branch:=master}"
: "${SampShell_git_branch_prefix:="$(whoami)"}"
# : "${SampShell_git_branch_prefix_pattern:='$SampShell_git_branch_prefix/??-??-??'}"

alias master-branch=SampShell_master_branch
SampShell_master_branch () {
	basename "$(git symbolic-ref refs/remotes/origin/HEAD -q || echo "${SampShell_git_default_master_branch?}")"
}

################################
# Interacting with remote code #
################################
alias gf='git fetch'
alias gpl='git pull'
alias gph='git push'
alias gphf='git push --force'
alias gst='git stash'
alias gstash=gst
alias gstp='git stash pop'

#####################
# Changing branches #
#####################

alias gnb='git new-branch'

alias gswm='gsw "$(SampShell_master_branch)"'
gsw () {
	[ "$#" = 0 ] && set -- '@{-1}'
	git switch "$@"
}
alias gbr='git branch'

gdb () {
	[ "$#" = 1 ] && [ "$1" = '-' ] && set -- 'HEAD~1'
	git branch --delete "$@"
}
alias grename='git branch --move'
alias gbmv=grename
alias gbrmv=grename


##########################
# Custom git "functions" #
##########################

gclear () {
	# git add --all && git stash push && git status
	echo 'todo'
	return 1
}

# Adds everything and prints out the status
function gaa {
	git add --all && git status
}

# Commits untracked files; all arguments are joined with a space.
function _SampShell-gcm {
	if [[ "$#" = 0 ]]; then
		git commit
	else
		git commit --message "$*"
	fi
}
alias gcm='noglob _SampShell-gcm'

alias gam='git commit --amend'
alias gcma='git commit --amend'
alias gammend='git commit --amend'

alias gs='git status'
alias grb='git rebase'
alias grbm='git rebase "$(master-branch)"'
alias grba='git rebase --abort'
alias ga='git add'

alias grs='git reset'
alias greset=grs
alias grm='git rm'
alias gco='git checkout'

alias gcp='git cherry-pick'
alias gg='git grep'
alias ginit='git init'

gnita () { gaa && gnit; }

gcl () {
	git clone "${1?'must supply a repo'}" || return "$?"
	set -- "$(basename "$1")"
	cd -- "${1%%.*}"
}

alias gl='git log'

alias gmm='gm "$(SampShell_master_branch)"'
gm () {
	[ "$#" = 0 ] && set -- '@{-1}'
	git merge "$@"
}
alias gma='git merge --abort'

alias gdm='gd "$(SampShell_master_branch)"'
alias gd='git diff'
gdh () {
	[ "$#" = 0 ] && set -- 'HEAD~1'
	gdh "$@"
}

alias gddm='gdd "$(SampShell_master_branch)"'
gdd () {
	[ "$#" = 0 ] && set -- 'HEAD~1'
	git diff --name-status "$@"
}
alias gdol=gdd
