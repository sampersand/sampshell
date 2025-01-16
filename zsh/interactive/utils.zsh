alias gcm='noglob gcm' # dont glob with gcm, eg dont have `!`s

# `prp` is a shorthand for `print -P`, which prints out a fmt string as if it were in the prompt.
function prp { print -P $@ }

alias hg='h | grep'

[[ $VENDOR == apple ]] && eval "${$(alias -L ls)}hGb" # add the `l` alias more options to `ls` which I know macOS supports
alias '%= ' '$= ' # Let's you paste commands in; a start `$` or `%` on its own is ignored.
alias d=dirs
alias mk=mkdir
alias parallelize-it=parallelize_it ## Create the shorthand for `parallelize-it`; TODO: do we stillw ant that

xx () repeat $2 print -rn -- $1

# Reloads the shell by rerunning all the ~/.zxxx` scripts.
# TODO: should we also load in the system config?
function reload {
	setopt -L LOCAL_TRAPS
	trap 'for file in ${ZDOTDIR:-$HOME}/.z(shenv|profile|shrc|login); do source ${file:P}; done' EXIT
}

## Git shorthand, make `@-X` be the same as `@{-X}`. this has to be in an anonymous function, else
# `i` will leak.
() {
	local i
	for (( i = 0; i < 10; i++ )); do
		alias -g "@-$i=@{-$i}"
	done
}

## Adds in "clean shell" functions, and the clsh alias
function clean-sh   { clean-shell --shell =sh $@ } # use which in case EQUALS is unset,
function clean-zsh  { clean-shell --shell =zsh $@ } # even though it's set by default.
function clean-bash { clean-shell --shell =bash $@ }
SampShell_command_exists dash && {
	function clean-dash { clean-shell --shell =dash $@ }
	function cldash { clean-dash --none -- -l $@ }
}
alias clsh=clean-shell
function clzsh { clean-zsh --none -- -fd $@ } # Don't set SampShell variables, only $TERM/$HOME,etc

# Removedir and mkdir aliases. Only removes directories with `.DS_Store` in them
rd () { builtin rm -f -- ${1:?need a dir}/.DS_Store && builtin rmdir -- $1 }
md () { builtin mkdir -p -- "${1:?missing a directory}" && builtin cd -- "$1" }

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

function enable-wifi { networksetup -setairportpower en0 on }
function disable-wifi { networksetup -setairportpower en0 off }
function toggle-wifi { disable-wifi; sleep 2; enable-wifi }

# Copies a previous command
cpcmd () { print -r -- $history[$((HISTCMD-${1:-1}))] | pbcopy }

alias banner='noglob ~ss/bin/banner' # Annoying cause banner is a builtin on macos
b80 () { banner "$@" | pbcopy }
b100 () { banner -w100 "$@" | pbcopy }
cc () { print -r $history[$(($#history - 0))] | pbcopy; }

pr () print -zr -- $ZLE_LINE_ABORTED
cpc () { print -r -- $history[${1:-$#history}] | tee "$(tty)" | pbcopy }


alias -- +x='chmod +x'
alias -- +rwx='chmod +rwx'
alias ps='ps -ax'
