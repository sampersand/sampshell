#!/bin/zsh

return # TODO

# if false; then
# 	# Gets the current branch (ISH---this isn't working)
# 	function git-current-branch () git rev-parse --abbrev-ref HEAD

# 	# Returns zero or nonzero depending on when on if it's in a repo.
# 	function is-in-a-git-repo () git rev-parse --is-inside-work-tree >&- 2>&-
# fi


##################
# Global aliases #
##################

alias g=git

for i in {1..10}; do
	alias -g "@-$i=@{-$i}"
done

#######################
# Helper git commands #
#######################

typeset -xgA _samp_shell_git_options
_samp_shell_git_options[default-master-branch]=master

function master-branch (){
	echo ${"$(git symbolic-ref refs/remotes/origin/HEAD -q || echo ${_samp_shell_git_options[default-master-branch]})":t}
}

# alias -g '$master-branch="$(master-branch)"'

function git-branch-prefix () {
	local prefix=${_samp_shell_git_options[branch-prefix]?set a branch prefix please}
	: ${1:=${date:-$(date +%y-%m-%d)}}
	[[ $1 =~ '([0-9]{2}-){2}[0-9]{2}' ]] || warn "$0: date isn't in the right format: $1"
	echo $prefix/$1
}

function git-branch-prefix-pattern () {
	echo "${(q)_samp_shell_git_options[branch-prefix]?}/??-??-??"
}

################################
# Interacting with remote code #
################################
alias gf='git fetch'
alias gpl='git pull'
alias gph='git push'
alias gphf='git push --force'
gremove-remote () {
	echo "not tested" && return
	git branch -d | xargs -L1 git branch -Dr
}

### Stashing Code
alias gst='git stash'
alias gstash=gst
alias gstp='git stash pop'



#####################
# Changing branches #
#####################

# Create a new branch; date is optional.
function gnb git-new-branch () {
	if [[ $# = 0 ]]; then eecho "[date=YY-MM-DD] $0 branch name here" && return -1; fi
	git switch --create "$(git-branch-prefix)/${(j:-:)@}"
}

function gsw () git switch ${@:-'@{-1}'}
alias gswm='gsw "$(master-branch)"'

alias gbr='git branch'




gdb () {
	[[ $# = 0 && $1 = '-' ]] && set -- '@{-1}'
	git branch --delete $@
}

alias grename='git branch --move'
alias gbmv=grename
alias gbrmv=grename


##########################
# Custom git "functions" #
##########################

# Squash all commits down lightly.
function gsquash git-squash () {
	if [[ $# != 1 ]]; then
		eecho "$0 <branch-or-commit>"
		return -1
	fi

	git reset --soft "$(git merge-base ${1?} HEAD)"
}

# Fixup code
function goops git-oops () {
	git add "${@:---all}" && git commit --amend --no-edit && git push --force
}

function gclear git-clear () {
	# git add --all && git stash push && git status
	echo 'todo'
}

# Adds everything and prints out the status
function gaa git-add-all () {
	git add --all && git status
}


##################################
# Extended builtin git functions #
##################################

# Commits untracked files; all arguments are joined with a space.
function gcm git-commit () git commit ${1+--message} ${(j: :)@}



###########
# Aliases #
###########

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
function gnita () { gaa && gnit }

gcl () { git clone ${1?'must supply a repo'} && cd ${1:t:r} }
alias gl='git log'

function gm () git merge ${@:-'@{-1}'}
alias gmm='gm "$(master-branch)"'
function gd () git diff ${@:-'@{-1}'}
alias gdm='gd "$(master-branch)"'
function gdd () git diff --name-status ${@:-'@{-1}'}
alias gddm='gdd "$(master-branch)"'

# 	# interact with remote
