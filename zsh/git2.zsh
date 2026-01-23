#!/bin/sh

# TODO: get rid of
alias gti=git # spellcheck

# Git shorthand, make `@-X` be the same as `@{-X}`.
alias -g '@-1=@{-1}' '@-2=@{-2}' '@-3=@{-3}' \
         '@-4=@{-4}' '@-5=@{-5}' '@-6=@{-6}' \
         '@-7=@{-7}' '@-8=@{-8}' '@-9=@{-9}'

# Registers commands as git alises
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

## Aliases based on normal git commands
galias ga{,a}                             # git add
galias gcm='noglob git cm' gcm{a,n,an,na} # git commit
galias gm{,m,a}                           # git merge
galias gd{,m,s,ms,no,h}                   # git diff
galias gsw{,m}                            # git switch
galias gbr{,c}                            # git branch
galias gph{,f}                            # git push
galias gpl                                # git pull
galias gs{,s}                             # git status
galias grb{,m,a}                          # git rebase
galias gco{,m}                            # git checkout
galias gst{,p} gstash                     # git stash
galias gf                                 # git fetch
galias grs                                # git reset
galias gl gls='git log-short'             # git log
galias gg                                 # git grep

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
gpristine () {
	git status &&
		read -q '?really clear changes it?' &&
		git reset --hard "$(git-master-branch)" && git clean -xdf
}
