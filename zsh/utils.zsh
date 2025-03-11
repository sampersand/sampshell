. ${0:P:h}/functions.zsh

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

grep () command grep --color=auto $@

alias -- +x='chmod +x'
alias -- +rwx='chmod +rwx'
alias ps='ps -ax'
alias hd='hexdump -C'
alias psg='noglob ps -ax | grep '

hr () xx ${@:--}
hrc () { hr | pbcopy }

################################################################################

sublzfiles () {
	subl ~/.z(shenv|shrc|profile|login|logout)
}

awkf () awk "BEGIN{$1; exit}"
+x-exp () +x ~ss/bin/experimental/${^@}

zfns () typeset -m '*_functions'

function -- -x { typeset +g -x SampShell_XTRACE=1; set -x; "$@" }
compdef -- _precommand -x

ufns () {
	preexec_functions=${preexec_functions:#_SampShell*}
	chpwd_functions=${chpwd_functions:#_SampShell*}
	precmd_functions=${precmd_functions:#_SampShell*}
	zshaddhistory_functions=${zshaddhistory_functions:#_SampShell*}
}
