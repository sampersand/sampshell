#!/bin/sh

## Git shorthand, make `@-X` be the same as `@{-X}`. this has to be in an anonymous function, else
# the var will leak
() while (( $# )) do
	alias -g "@-$1=@{-$1}"
	shift
done $(seq 1 10)

alias g=git

galias () {
	local tmp
	for tmp do alias ${tmp}="g ${tmp#g}"; done
}

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
galias gf
galias gpl
galias gph
galias gphf

alias gpr='git create-pr'
alias gprv='gh pr view --web'

# function ghcl () { gh repo clone ${${1:?}#https://github.com/} && cd $_:t }
# function gcl () {
# 	git clone "${1?'must supply a repo'}" || return "$?"
# 	set -- "$(basename "$1")"
# 	cd -- "${1%%.*}"
# }

################################################################################
#                                     TODO                                     #
################################################################################

galias gdirs
galias gnit
galias goops
galias gsquash

## Spellcheck
alias gti=git
alias gi='git ignore'

################################
# Interacting with remote code #
################################
galias gst gstash
galias gstp

#####################
# Changing branches #
#####################

galias gnb

galias gsw
galias gswm
galias gbr
galias gbrc

alias grename='git branch --move' # TODO: clean this up

##########################
# Custom git "functions" #
##########################

galias ga
galias gaa

alias gcm='noglob git cm'
galias gcma
galias gcmn
galias gcman gcmna

################################################################################
#                                   Merging                                    #
################################################################################

galias gm
galias gmm
galias gma

################################################################################
#                                    Diffs                                     #
################################################################################

galias gd
galias gdm
galias gds
galias gdms
galias gdno
galias gdh

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

galias gs
galias gss
galias grb
galias grbm
galias grba

galias grs
galias grm
galias gco
galias gcom

galias gcp
galias gg
galias gl
alias gls='git log-short'

# gnita () { gaa && gnit; }

# alias gl='git log'
