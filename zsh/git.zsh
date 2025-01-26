## TODO: This file was originally 100%` sh-compliant, so now we should clean that up and make it more
# zsh-like.

gm  () git merge ${@:-'@{-1}'}
gmm () git merge "$(SampShell_master_branch)"
gma () git merge --abort

grb  () git rebase ${@:-'@{-1}'}
grbm () git rebase "$(SampShell_master_branch)"
grba () git rebase --abort

gcp  () git cherry-pick $@
gcpa () git cherry-pick --abort

ga   () git add $@
gaa  () { git add --all && git status }

function gam () git commit --ammend ${1:+--message} "$*"
alias gam='noglob gam'

function gcm () git commit ${1:+--message} "$*"
alias gcm='noglob gcm'

gsw  () git switch ${@:-'@{-1}'}
gswm () git switch "$(SampShell_master_branch)"

gs  () git status $@
gss () git status -s $@

################################################################################

#---------

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

SampShell_git_branch_prefix () {
	if [ -z "$1" ]; then
		set -- "${date:-"$(date +%y-%m-%d)"}"
	fi

	case "$1" in
		[0-9][0-9]-[0-9][0-9]-[0-9][0-9])
			;;
		*)
			echo "$0: Date isn't in the right format: $1" >&2
			return 1 ;;
	esac

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
	if [ "$#" = 0 ]; then
		echo "[date=YY-MM-DD] $0 (branch name here)" >&2
		return 255
	fi

	git switch --create "$(SampShell_git_branch_prefix)/$(IFS='-' ; echo "$*")"
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

# Squash all commits down lightly.
gsquash () {
	if [ "$#" != 1 ]; then
		echo "usage: $0 <branch-or-commit>"
		return 255
	fi

	git reset --soft "$(git merge-base "${1?}" HEAD)"
}

# Fixup code
function goops {
	git add --all && git commit --amend --no-edit && git push --force
}

gclear () {
	# git add --all && git stash push && git status
	echo 'todo'
	return 1
}

alias grs='git reset'
alias greset=grs
alias grm='git rm'
alias gco='git checkout'

alias gg='git grep'
alias ginit='git init'
alias gnit='git commit --amend --no-edit'

gnita () { gaa && gnit; }

gcl () {
	git clone "${1?'must supply a repo'}" || return "$?"
	set -- "$(basename "$1")"
	cd -- "${1%%.*}"
}

alias gl='git log'


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
