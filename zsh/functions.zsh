# Adds in "clean shell" aliases, which startup a clean version of shells, and only set "normal"
# vars such as $TERM/$HOME etc. Relies on my `clean-shell` function being in `$PATH`.
alias   clsh='clean-shell sh'
alias clbash='clean-shell bash'
alias  clzsh='clean-shell zsh'
alias cldash='clean-shell dash'

## Banner utility
alias banner='noglob ~ss/bin/universal/banner'
alias b80='banner --copy --width=80'
alias b100='banner --copy --width=100'

## Debugging utilities
function pa {
	local a b i=0
	if [[ ${(tP)1} = array-* ]]; then
		p ${(P)1}
	else
		for a b in ${(kvP)1}; do
			printf "%3d: %-20s%s\n" $((i++)) $a $b
		done
	fi
}
## Adding default arguments to builtin commands
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ps='ps -ax'
