## Register functions; We use an anonymous function so `fn` doesn't escape
() {
	fpath+=($1)

	local fn
	for fn in $1/*(:t); do
		autoload -Uz $fn
		zle -N $fn
	done
} ${0:P:h}/keybind-functions

autoload -Uz SampShell-delete-backto-char

function clear-screen { cls && zle reset-prompt }
zle -N clear-screen

function pound-insert { BUFFER="$histchars[3] $BUFFER"; zle accept-line }
zle -N pound-insert

function _SampShell-zle-add-pbcopy {
	# Add a space unless there's already a space
	[[ ${BUFFER: -1} = [[:blank:]] ]] || BUFFER+=' '
	BUFFER+='| pbcopy'
	zle redisplay
}

function _SampShell-zle-make-prompt-simple {
	local PS1
	zstyle -s ':sampshell:bindkey:simple-prompt' PS1 PS1 || PS1='%% '
	zle reset-prompt
}

function _SampShell-zle-put-back-zle {
	BUFFER[CURSOR+1,CURSOR]=$ZLE_LINE_ABORTED
	CURSOR+=$#ZLE_LINE_ABORTED
	zle redisplay
}

() {
	local cmd
	for cmd in ${(kM)functions:#_SampShell-zle*} do
		zle -N ${cmd#_} $cmd
	done
}
