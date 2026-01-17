#!/bin/sh

# TODO: get rid of
: "${SampShell_git_branch_prefix:="$(whoami)"}"

## Git shorthand, make `@-X` be the same as `@{-X}`. this has to be in an anonymous function, else
# the var will leak
() while (( $# )) do
	alias -g "@-$1=@{-$1}"
	shift
done $(seq 1 10)

alias g=git

################################################################################
#                              Everyday Commands                               #
################################################################################

################################################################################
#                               Fixing Problems                                #
################################################################################

################################################################################
#                                Collaboration                                 #
################################################################################
alias gru='git remote-url'
function gruo () {
	if [[ $1 == -h ]] { git remote-url -h >&2; return }
	local remote
	remote=$(git remote-url $@) || return
	open $remote
}
function gruc () {
	if [[ $1 == -h ]] { git remote-url -h >&2; return }
	git remote-url $@ | pbc
}

alias gopen=gruo gopenc=gruc
alias gf='git fetch'
alias gpl='git pull'
alias gph='git push'
alias gphf='git push --force'

alias gpr='git create-pr'
alias gprv='gh pr view --web'

function ghcl () { gh repo clone ${${1:?}#https://github.com/} && cd $_:t }
function gcl () {
	git clone "${1?'must supply a repo'}" || return "$?"
	set -- "$(basename "$1")"
	cd -- "${1%%.*}"
}

################################################################################
#                                     TODO                                     #
################################################################################

alias gdirs='git prev-branches'
alias gnit='git nit'
alias goops='git oops'
alias gsquash='git squash'

## Spellcheck
alias gti=git
alias gi='git ignore'

################################
# Interacting with remote code #
################################
alias gst='git stash'
alias gstash=gst
alias gstp='git stash pop'

#####################
# Changing branches #
#####################

alias gnb='git new-branch'

function gsw () git switch "${@:-@{-1\}}"
alias    gswm='git switch "$(git-master-branch)"'
alias    gbr='git branch'
alias    gbrc='git branch --show-current'

alias grename='git branch --move' # TODO: clean this up

##########################
# Custom git "functions" #
##########################

alias ga='git add'
function gaa () { git add --all && git status }

alias gcm='noglob git commit-msg'
alias gcma='gcm --amend'
alias gcmn='gcm --no-verify'
alias gcman='gcm --amend --no-verify' gcmna=gcman

################################################################################
#                                   Merging                                    #
################################################################################

function gm () git merge "${@:-@{-1\}}"
alias gmm='git merge "$(git master-branch)"'
alias gma='git merge --abort'

################################################################################
#                                    Diffs                                     #
################################################################################

alias gd='git diff'
alias gdm='git diff "$(git master-branch)"'
alias gds='git diff --stat'
alias gdms='git diff --stat "$(git master-branch)"'

alias gdno='git diff --name-only'
gdh () {
	if (( $# == 0 )) set -- 'HEAD~1'
	git diff "$@"
}

################################################################################
#                                     Misc                                     #
################################################################################

# --
gpristine () {
	git status &&
		read -q '?really clear changes it?' &&
		git reset --hard "$(git-master-branch)" && git clean -xdf
}

alias gisancestor='git merge-base --is-ancestor'

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

alias gl='git log'
