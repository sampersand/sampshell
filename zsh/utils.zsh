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

szfiles () subl ~/.z(shenv|shrc|profile|login|logout)
szrc () subl ~/.zshrc

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
asciichars=$'\x00\x01\x02\x03\x04\x05\x06\a\b\t\n\v\f\r\x0E\x0F\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\e\x1C\x1D\x1E\x1F !\"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~\x7F\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8A\x8B\x8C\x8D\x8E\x8F\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9A\x9B\x9C\x9D\x9E\x9F\xA0\xA1\xA2\xA3\xA4\xA5\xA6\xA7\xA8\xA9\xAA\xAB\xAC\xAD\xAE\xAF\xB0\xB1\xB2\xB3\xB4\xB5\xB6\xB7\xB8\xB9\xBA\xBB\xBC\xBD\xBE\xBF\xC0\xC1\xC2\xC3\xC4\xC5\xC6\xC7\xC8\xC9\xCA\xCB\xCC\xCD\xCE\xCF\xD0\xD1\xD2\xD3\xD4\xD5\xD6\xD7\xD8\xD9\xDA\xDB\xDC\xDD\xDE\xDF\xE0\xE1\xE2\xE3\xE4\xE5\xE6\xE7\xE8\xE9\xEA\xEB\xEC\xED\xEE\xEF\xF0\xF1\xF2\xF3\xF4\xF5\xF6\xF7\xF8\xF9\xFA\xFB\xFC\xFD\xFE\xFF'
