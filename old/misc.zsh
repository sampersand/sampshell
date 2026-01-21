## Shorthand for functions to ensure that the right arguments are given. It's an alias
# so it shoudl be the first thing. Example:
#	gs () ARGC_EXACTLY_0 git status
() {
	local i
	for i in {0..9}; do
		alias ARGC_EXACTLY_$i='${${$(((#=='$i'))&&print x):?exactly '$i' args needed}:#*} '
		alias ARGC_AT_MOST_$i='${${$(((#<='$i'))&&print x):?at most '$i' args needed}:#*} '
	done
}

# overwrite the `pbc` command to chomp arguments; no longer neeeded, this is done now
pbc () { if [[ $# ]] then command pbc $@; else chomp | command pbc; fi }


alias ps='ps -ax'
alias hd='hexdump -C' # `p` has kinda taken over the need for this

alias psg='noglob ps -ax | grep ' # `pg` has kinda taken over this

# `h` now has this builtin
function _SampShell-hg { h | grep $* }
alias hg='noglob _SampShell-hg'

# i never need to do this lol
alias -- +rwx='chmod +rwx'

# most commands to have `_SampShell` as a prefix anymore
ufns () {
	preexec_functions=${preexec_functions:#_SampShell*}
	chpwd_functions=${chpwd_functions:#_SampShell*}
	precmd_functions=${precmd_functions:#_SampShell*}
	zshaddhistory_functions=${zshaddhistory_functions:#_SampShell*}
}
