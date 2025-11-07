#!/bin/sh

# TODO: get rid of
: "${SampShell_git_branch_prefix:="$(whoami)"}"

. ${0:P:h}/deprecated.zsh

## Git shorthand, make `@-X` be the same as `@{-X}`. this has to be in an anonymous function, else
# the var will leak
() while (( $# )) do
	alias -g "@-$1=@{-$1}"
	shift
done $(seq 1 10)

alias g=git
alias gdirs='git prev-branches'
alias gnit='git nit'
alias goops='git oops'
function gopen () {
	if [[ $1 == -h ]] { git remote-url -h >&2; return }
	local remote
	remote=$(git remote-url $@) || return
	open $remote
}

function gopenc () { git remote-url $@ | pbc; }
alias gru='git remote-url'
alias gruc='gopenc'
alias gsquash='git squash'

## Spellcheck
alias gti=git
alias ig='__deprecated git ignore'
alias gi='git ignore'

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

function gsw () git switch "${@:-'@{-1}'}"
alias    gswm='git switch "$(git-master-branch)"'
alias    gbr='git branch'
alias    gbrc='__deprecated git branch --show-current'

alias gdb='__deprecated git branch --delete'
alias gbrd='git branch --delete'
alias grename='git branch --move' # TODO: clean this up
alias gbmv='__deprecated git branch --move'
alias gbrmv='__deprecated git branch --move'


##########################
# Custom git "functions" #
##########################

alias ga='git add'
function gaa () { git add --all && git status }

# Commits untracked files; all arguments are joined with a space.
function _SampShell-gcm {
	emulate -L zsh

	# Any flags that are passed just keep them
	local msg=() args=()

	while (( $# )) {
		case $1 in
		--) shift; msg+=( $@ ); break ;;
		-*) args+=( $1 ) ;;
		*)  msg+=( $1 ) ;;
		esac
		shift
	}

	git commit ${args} ${msg:+--message="$msg"}
}

alias gcm='noglob _SampShell-gcm'
alias gcma='gcm --amend'
alias gcmn='gcm --no-verify'
alias gcman='gcm --amend --no-verify' gcmna=gcman

alias gam='__deprecated git commit --amend'
alias gammend='__deprecated git commit --amend'

alias gs='STTY=noflsh git status' # TODO: we have the STTY here, do we want that?
alias gss='git status --short'
alias grb='git rebase'
alias grbm='git rebase "$(git-master-branch)"'
alias grba='git rebase --abort'

alias grs='git reset'
alias greset=grs
alias grm='git rm'
alias gco='git checkout'
alias gcom='git checkout "$(git-master-branch)" --'

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

alias gmm='gm "$(git-master-branch)"'
gm () {
	[ "$#" = 0 ] && set -- '@{-1}'
	git merge "$@"
}
alias gma='git merge --abort'

alias gdm='gd "$(git-master-branch)"'
alias gd='git diff'
alias gdno='git diff --name-only'
alias gds='git diff --name-status'

gdh () {
	[ "$#" = 0 ] && set -- 'HEAD~1'
	gdh "$@"
}

alias gddm='gdd "$(git-master-branch)"'
gdd () {
	[ "$#" = 0 ] && set -- 'HEAD~1'
	git diff --name-status "$@"
}
alias gdol=gdd

# --
gpristine () {
	git status &&
		read -q '?really clear changes it?' &&
		git reset --hard "$(git-master-branch)" && git clean -xdf
}

alias gpr='git create-pr'
alias gprv='gh pr view --web'

alias gw='gh pr view --web'
ghcl () { gh repo clone ${${1:?}#https://github.com/} && cd $_:t }
alias gisancestor='git merge-base --is-ancestor'
