#!/bin/sh

# TODO: get rid of
: "${SampShell_git_branch_prefix:="$(whoami)"}"
alias gti=git
alias g=git

## Git shorthand, make `@-X` be the same as `@{-X}`. this has to be in an anonymous function, else
# the var will leak
() while (( $# )) do
	alias -g "@-$1=@{-$1}"
	shift
done $(seq 1 10)

galias () {
	local git_alias
	for git_alias do
		if [[ $git_alias = *=* ]] then
			alias "$git_alias"
		else
			alias ${git_alias}="git ${git_alias#g}"
		fi
	done
}

# --
gpristine () {
	git status &&
		read -q '?really clear changes it?' &&
		git reset --hard "$(git-master-branch)" && git clean -xdf
}

################################################################################
#                        Direct aliases from .gitconfig                        #
################################################################################

galais ga{,a}                                   # git add
galias gcm='noglob git cm' gcm{a,n,an,na}       # git commit
galias gm{,m,a}                                 # git merge
galias gd{,m,s,ms,no,h}                         # git diff
galias gsw{,m}                                  # git switch
galias gbr{,c}                                  # git branch
galias gph{,f}                                  # git push
galias gpl                                      # git pull
galias gs{,s}                                   # git status
galias grb{,m,a}                                # git rebase
galias gco{,m}                                  # git checkout
galias gst{,p} gstash                           # git stash
galias gf                                       # git fetch
galias grs                                      # git reset
galias gl gls='git log-short'                   # git log
galias gg                                       # git grep

## Aliases based on custom commands
galias gdirs     # git dirs
galias gnit      # git nit
galias goops     # git oops
galias gsquash   # git squash
galias gnb       # git new-branch
galias gpr{,v}   # git create-pr AND gh pr view --web
galias gru{,o,c} # git remote-url
alias gopen=gro gopenc=gruoc

## Aliases IDK if I need, or should fixup
galias gisancestor
galias gi='git ignore'
galias grename='git branch --move' # TODO: clean this up
# galias grm              # git rm; idk how often i use this
# galias gcp              # git cp; idk how often i use this
