alias gcm='noglob gcm' # dont glob with gcm, eg dont have `!`s

[[ $VENDOR == apple ]] && eval "${$(alias -L ls)}hGb" # add the `l` alias more options to `ls` which I know macOS supports
alias '%= ' '$= ' # Let's you paste commands in; a start `$` or `%` on its own is ignored.
alias d=dirs
alias mk=mkdir
alias parallelize-it=parallelize_it ## Create the shorthand for `parallelize-it`; TODO: do we stillw ant that

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
SampShell_command_exists dash && function clean-dash { clean-shell --shell =dash $@ }
alias clsh=clean-shell
function clzsh { clean-zsh --none -- -fd $@ } # Don't set SampShell variables, only $TERM/$HOME,etc

# Removedir and mkdir aliases. Only removes directories with `.DS_Store` in them
rd () { builtin rm -f -- ${1:?need a dir}/.DS_Store && builtin rmdir -- $1 }
md () { builtin mkdir -p -- "${1:?missing a directory}" && builtin cd -- "$1" }

source ${0:P:h}/extended/utils.zsh
