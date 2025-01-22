
: "${SampShell_git_default_master_branch:=master}"
: "${SampShell_git_branch_prefix:="$(whoami)"}"
# : "${SampShell_git_branch_prefix_pattern:='$SampShell_git_branch_prefix/??-??-??'}"

####################################################################################################
#                                           Remote Code                                            #
####################################################################################################

alias gf='git fetch'
alias gpl='git pull'
alias gph='git push'
alias gphf='git push --force'

[[ -n $SampShell_no_experimental ]] && alias gclean-branch='git reset --hard master/origin'

# Clones a repo
function gcl {
	git clone ${1?must supply a repo} || return $?
	cd -- ${1:r:t}
}

####################################################################################################
#                                             Branches                                             #
####################################################################################################

# Create a new branch; date is optional.
function gnb { # TODO: GNB with date and stuff
	if (( $# == 0 )) then
		print >&2 "usage: [date=YY-MM-DD] $0 (branch name here)"
		return 255
	fi

	git switch --create "$(SampShell_git_branch_prefix)/$(IFS='-' ; echo "$*")"
}

function gsw { git switch ${@:-'@{-1}'} }
alias gswm='gsw "$(SampShell_master_branch)"'
alias gbr='git branch'

gbrd () {
	[[ $# == 1 && $1 == - ]] && set -- 'HEAD~1'
	git branch --delete $@
}

alias grename='git branch --move'
alias gbmv=grename
alias gbrmv=grename

####################################################################################################
#                                            Local Code                                            #
####################################################################################################


# ---

alias gs='git status'

alias gst='git stash'
alias gstash=gst
alias gstp='git stash pop'

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

# Adds everything and prints out the status
function gaa { git add --all && git status }

# Commits untracked files; all arguments are joined with a space.
function _SampShell-gcm {
	if (( $# == 0 )) then
		git commit
	else
		git commit --message "$*"
	fi
}
alias gcm='noglob _SampShell-gcm'
alias gam='git commit --amend'
alias gcma='git commit --amend'x
alias gammend='git commit --amend'
alias ga='git add'

alias grs='git reset'
alias greset=grs
alias grm='git rm'
alias gco='git checkout'



################################################################################
#                                      -                                       #
################################################################################


--

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


gclear () {
	# git add --all && git stash push && git status
	echo 'todo'
	return 1
}

alias grb='git rebase'
alias grbm='git rebase "$(master-branch)"'
alias grba='git rebase --abort'

alias gcp='git cherry-pick'
alias gg='git grep'
alias ginit='git init'
alias gnit='git commit --amend --no-edit'

gnita () { gaa && gnit; }

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
