export SampShell_HOME="${SampShell_HOME:-"$HOME/.sampshell"}"

. "$SampShell_HOME/non-interactive.sh"

alias s=subl
alias ss=ssubl

SampShell_nargs () { echo $#; }
SampShell_isalias nargs || alias nargs=SampShell_nargs

: ${SampShell_words:=/usr/share/dict/words}
[ -e "$SampShell_words" ] || unset SampShell_words
[ -n "$SampShell_words" ] && words=SampShell_words
