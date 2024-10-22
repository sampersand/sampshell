#!/bin/zsh

alias g=git

: "${SampShell_git_default_master_branch:=master}"
: "${SampShell_git_branch_prefix:="$(whoami)"}"
: "${SampShell_git_branch_prefix_pattern:='$SampShell_git_branch_prefix/??-??-??'}"

alias master-branch=SampShell_master_branch
SampShell_master_branch () {
	basename "$(git symbolic-ref refs/remotes/origin/HEAD -q || echo "${SampShell_git_default_master_branch?}")"
}

echo "todo: regex matching"
SampShell_git_branch_prefix () {
	if [ -z "$1" ]; then
		set -- "${date:-"$(date +%y-%m-%d)"}"
	fi

	[[ $1 =~ '([0-9]{2}-){2}[0-9]{2}' ]] || warn "$0: date isn't in the right format: $1"
	echo "${SampShell_git_branch_prefix?}/$1"
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

# Create a new branch; date is optional.
gnb () {
	if [ $# = 0 ]; then
		echo "[date=YY-MM-DD] $0 (branch name here)" >&2
		return 255
	fi

	if [ -n "$ZSH_VERSION" ]; then echo "todo: join in sh"; return 1; fi

	git switch --create "$(SampShell_git_branch_prefix)/${(j:-:)@}"
}

alias gswm='gsw "$(SampShell_master_branch)"'
gsw () {
	[ $# = 0 ] && set -- '@{-1}'
	git switch "$@"
}
alias gbr='git branch'

gdb () {
	[ $# = 1 ] && [ "$1" = '-' ] && set -- '@{-1}'
	git branch --delete "$@"
}
alias grename='git branch --move'
alias gbmv=grename
alias gbrmv=grename


##########################
# Custom git "functions" #
##########################

# Squash all commits down lightly.
gsquash () {
	if [ $# != 1 ]; then
		echo "usage: $0 <branch-or-commit>"
		return 255
	fi

	git reset --soft "$(git merge-base "${1?}" HEAD)"
}

# Fixup code
goops () {
	[ $# = 0 ] && set -- '--all'
	git add "$@" && git commit --amend --no-edit && git push --force
}

gclear () {
	# git add --all && git stash push && git status
	echo 'todo'
	return 1
}

# Adds everything and prints out the status
gaa () {
	git add --all && git status
}

# Commits untracked files; all arguments are joined with a space.
gcm () if [ $# = 0 ]; then
	git commit
else
	echo '<gcm: todo: what if the argument starts with `-`?>'
	git commit ${1+--message} "$*"
fi

alias gs='git status'
alias grb='git rebase'
alias grbm='git rebase "$(master-branch)"'
alias ga='git add'

alias grs='git reset'
alias greset=grs
alias grm='git rm'
alias gco='git checkout'

alias gcp='git cherry-pick'
alias gg='git grep'
alias ginit='git init'
alias gnit='git commit --amend --no-edit'
gnita () { gaa && gnit; }

gcl () { git clone ${1?'must supply a repo'} && cd ${1:t:r}; }
alias gl='git log'

alias gmm='gm "$(SampShell_master_branch)"'
gm () {
	[ $# = 0 ] && set -- '@{-1}'
	git merge "$@"
}

alias gdm='gd "$(SampShell_master_branch)"'
gd () {
	[ $# = 0 ] && set -- '@{-1}'
	git diff "$@"
}

alias gddm='gdd "$(SampShell_master_branch)"'
gdd () {
	[ $# = 0 ] && set -- '@{-1}'
	git diff --name-status "$@"
}
