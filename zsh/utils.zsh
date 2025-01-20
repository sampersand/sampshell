. ${0:P:h}/functions.zsh

function copy-to-clipboard {
	if (( $# == 0 )) then
		pbcopy
	else
		print -nr -- $* | copy-to-clipboard
	fi
}

[[ $VENDOR == apple ]] && source ${0:P:h}/macos.zsh

# `prp` is a shorthand for `print -P`, which prints out a fmt string as if it were in the prompt.
function prp { print -P $@ } # NOTE: You can also use `print ${(%)@}`

alias hg='h | grep'

alias '%= ' '$= ' # Let's you paste commands in; a start `$` or `%` on its own is ignored.
alias d=dirs
alias mk=mkdir
alias parallelize-it=parallelize_it ## Create the shorthand for `parallelize-it`; TODO: do we stillw ant that

xx () { repeat $2 print -rn -- $1; print }

# Reloads the shell by rerunning all the ~/.zxxx` scripts.
# TODO: should we also load in the system config?
function reload {
	unalias gcm >/dev/null 2>/dev/null # TODO: shoudl this be `unalias -a`?
	setopt -L LOCAL_TRAPS
	trap 'for file in ${ZDOTDIR:-$HOME}/.z(shenv|profile|shrc|login); do source ${file:P}; done' EXIT
}

# Removedir and mkdir aliases. Only removes directories with `.DS_Store` in them
rd () { command rm -f -- ${1:?need a dir}/.DS_Store && command rmdir -- $1 }
md () { command mkdir -p -- "${1:?missing a directory}" && command cd -- "$1" }

# utility functions and what have you that I've accumulated over the years
chr () ruby -- /dev/fd/3 $@ 3<<'RUBY'
puts ([]==$*?$stdin.map(&:chomp):$*).map{|w|w.bytes.map{_1.to_s 16}.join(?\s)}
RUBY
# $*.empty? and $*.replace $stdin.map(&:chomp)
# puts $*.map{|w|w.bytes.map{|b|b.to_s 16}.join(?\s)}

ord () ruby -- /dev/fd/3 $@ 3<<'RUBY'
puts ($*.empty? ? $stdin.map{_1.chomp.split} : [$*])
	.map{_1.map(&:hex).pack('C*')}
RUBY

# Copies a previous command
cpcmd () { print -r -- $history[$((HISTCMD-${1:-1}))] | SampShell-copy }
cc () { print -r $history[$(($#history - 0))] | SampShell-copy; }

pr () print -zr -- $ZLE_LINE_ABORTED
cpc () { print -r -- $history[${1:-$#history}] | tee "$(tty)" | SampShell-copy }

alias -- +x='chmod +x'
alias -- +rwx='chmod +rwx'
alias ps='ps -ax'

################################################################################

bindkey -r '^[ '
function put-back-zle {
	BUFFER+=$ZLE_LINE_ABORTED
	(( CURSOR += $#ZLE_LINE_ABORTED ))
	zle redisplay
}
zle -N put-back-zle

function copy-current-command {
	: ${NUMERIC:=0}
	if (( NUMERIC )) then
		echo todo
	else
		print -rn -- $BUFFER | pbcopy
	fi
	zle -M "copied: $BUFFER"
}
zle -N copy-current-command

# pr () print -zr -- $ZLE_LINE_ABORTED
bindkey '^[ z' put-back-zle
bindkey '^[ c' copy-current-command
bindkey '^[ p' SampShell-add-pbcopy

# bindkey -N SampShell-git
bindkey -s '^[gaa' '^Qgit add --all^M'
bindkey -s '^[gs'  '^Qgit status^M'
