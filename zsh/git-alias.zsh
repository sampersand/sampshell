#!/bin/sh

# TODO: get rid of
: "${SampShell_git_branch_prefix:="$(whoami)"}"

## Git shorthand, make `@-X` be the same as `@{-X}`. this has to be in an anonymous function, else
# the var will leak
() while (( $# )) do
	alias -g "@-$1=@{-$1}"
	shift
done $(seq 1 10)

alias gti=git
alias g=git

################################################################################
#                              Shorthand Commands                              #
################################################################################

# git add
alias    ga='git add'
function gaa () { git add --all && git status }

# git commit
alias    gcm='noglob git commit-msg'
alias    gcma='gcm --amend'
alias    gcmn='gcm --no-verify'
alias    gcman='gcm --amend --no-verify' gcmna=gcman

# git merge
function gm () git merge "${@:-@{-1\}}"
alias    gmm='git merge "$(git master-branch)"'
alias    gma='git merge --abort'

# git diff
alias    gd='git diff'
alias    gdm='git diff "$(git master-branch)"'
alias    gds='git diff --stat'
alias    gdms='git diff --stat "$(git master-branch)"'
alias    gdno='git diff --name-only'
function gdh () { git diff "${@:-HEAD~1}" }

# git switch
function gsw () git switch "${@:-@{-1\}}"
alias    gswm='git switch "$(git-master-branch)"'

# git branch
alias    gbr='git branch'
alias    gbrc='git branch --show-current'

# git push
alias    gph='git push'
alias    gphf='git push --force'

# git pull
alias    gpl='git pull'

# git status
alias    gs='git status'
alias    gss='git status --short'

# git rebase
alias    grb='git rebase'
alias    grbm='git rebase "$(git-master-branch)"'
alias    grba='git rebase --abort'

# git checkout
alias    gco='git checkout'
alias    gcom='git checkout "$(git-master-branch)" --'

# git stash
alias    gst='git stash' gstash=gst
alias    gstp='git stash pop'

# git fetch
alias    gf='git fetch'

# git reset
alias    grs='git reset'

# git log
alias    gl='git log'
alias    gls='git log-short'

# git grep
alias    gg='git grep'

################################################################################
#                               Custom Commands                                #
################################################################################

alias gdirs='git prev-branches'
alias gnit='git nit'
alias goops='git oops'
alias gsquash='git squash'
alias gnb='git new-branch'

alias gpr='git create-pr'
alias gprv='gh pr view --web'

alias gru='git remote-url'
function gruo () {
	if [[ $1 == -h ]] { git remote-url -h >&2; return 1 }
	local remote
	remote=$(git remote-url $@) || return
	open $remote
}
function gruc () {
	if [[ $1 == -h ]] { git remote-url -h >&2; return 1 }
	git remote-url $@ | pbc
}

alias gisancestor='git merge-base --is-ancestor'
alias grename='git branch --move' # TODO: clean this up

gpristine () {
	git status &&
		read -q '?really clear changes it?' &&
		git reset --hard "$(git-master-branch)" && git clean -xdf
}
