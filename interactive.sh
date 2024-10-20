export SampShell_HOME="${SampShell_HOME:-"$HOME/.sampshell"}"

. "$SampShell_HOME/non-interactive.sh"

for file in "$SampShell_HOME"/shared/*; do
	. "$file"
done

[ -n "$ZSH_VERSION" ] && for file in "$SampShell_HOME"/zsh/*; do
	. "$file"
done


# . "$SampShell_HOME/non-interactive.sh"
# . "$SampShell_HOME/git.sh"
# . "$SampShell_HOME/prompt.sh"
# . "$SampShell_HOME/safety.sh"

alias s=subl
alias ss=ssubl

SampShell_nargs () { echo $#; }
SampShell_isalias nargs || alias nargs=SampShell_nargs

: ${SampShell_words:=/usr/share/dict/words}
[ -e "$SampShell_words" ] || unset SampShell_words
[ -n "$SampShell_words" ] && words=SampShell_words
