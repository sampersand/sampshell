. ${0:P:h}/functions.zsh

function copy-to-clipboard {
	if (( $# == 0 )) then
		pbcopy
	else
		print -nr -- $* | copy-to-clipboard
	fi
}

[[ $VENDOR == apple ]] && source ${0:P:h}/macos.zsh

function ducks {
	du -chs -- $@ | sort -h
}
# `prp` is a shorthand for `print -P`, which prints out a fmt string as if it were in the prompt.
function prp { print -P $@ } # NOTE: You can also use `print ${(%)@}`

function _SampShell-hg { h | grep $* }
alias hg='noglob _SampShell-hg'

alias '%= ' '$= ' # Let's you paste commands in; a start `$` or `%` on its own is ignored.
alias mk=mkdir
alias parallelize-it=parallelize_it ## Create the shorthand for `parallelize-it`; TODO: do we stillw ant that

# Reloads the shell by rerunning all the ~/.zxxx` scripts.
# TODO: should we also load in the system config?
function reload {
	unset SampShell_interactive_loaded
	unalias h gcm >/dev/null 2>/dev/null # TODO: shoudl this be `unalias -a`?
	setopt -L LOCAL_TRAPS
	trap 'for file in ${ZDOTDIR:-$HOME}/.z(shenv|profile|shrc|login); do source ${file:P}; done' EXIT
}

# Removedir and mkdir aliases. Only removes directories with `.DS_Store` in them
rd () { command rm -f -- ${1:?need a dir}/.DS_Store && command rmdir -- $1 }
# md () { command mkdir -p -- "${1:?missing a directory}" && command cd -- "$1" }

# utility functions and what have you that I've accumulated over the years
false && chr () ruby -- /dev/fd/3 $@ 3<<'RUBY'
puts ([]==$*?$stdin.map(&:chomp):$*).map{|w|w.bytes.map{_1.to_s 16}.join(?\s)}
RUBY
# $*.empty? and $*.replace $stdin.map(&:chomp)
# puts $*.map{|w|w.bytes.map{|b|b.to_s 16}.join(?\s)}

false && ord () ruby -- /dev/fd/3 $@ 3<<'RUBY'
puts ($*.empty? ? $stdin.map{_1.chomp.split} : [$*])
	.map{_1.map(&:hex).pack('C*')}
RUBY

# Copies a previous command
cpcmd () { print -r -- $history[$((HISTCMD-${1:-1}))] | pbc }
copycmd () { print -r $history[$(($#history - 0))] | pbc; }

prl () print -zr -- $ZLE_LINE_ABORTED
cpc () { print -r -- $history[${1:-$#history}] | tee "$(tty)" | pbc }


grep () command grep --color=auto $@
alias -- +x='chmod +x'
alias -- +rwx='chmod +rwx'
alias ps='ps -ax'
alias hd='hexdump -C'
alias psg='noglob ps -ax | grep '

hr () xx ${@:--}
hrc () { hr | pbcopy }

################################################################################

tracezsh2 () {
	clean-shell --none \
		--var PS4='+$(typeset -Fg SECONDS; echo "$SECONDS"):%x:%I> ' \
		--var SampShell_just_for_testing_should_disable_rvm=1 \
		-xil \
		-o promptsubst \
		-c exit
}

tracezsh () {
	clean-shell --none \
		--var SampShell_PROFILE= \
		--var SampShell_SOURCETRACE=1 \
		--var SampShell_XTRACE=1 \
		--var SampShell_ROOTDIR \
		--var SampShell_just_for_testing_should_disable_rvm=1 \
		--xtrace \
		--sourcetrace \
		${@:?need a command to run!}
		# --command :
		# -xilcosourcetrace :
}

sublzfiles () {
	subl ~/.z(shenv|shrc|profile|login|logout)
}

awkf () awk "BEGIN{$1; exit}"
+x-exp () +x ~ss/bin/experimental/${^@}
