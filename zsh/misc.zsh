old () git mv $1 ~ss/old/${1#~ss}

if [[ $VENDOR == apple ]] {
	function  enable-wifi { networksetup -setairportpower en0 on }
	function disable-wifi { networksetup -setairportpower en0 off }
	function  toggle-wifi { disable-wifi; sleep 2; enable-wifi }
}

function ducks { du -chs -- $@ | sort -h }

diffs () { if (( $# != 2 )) { echo "need 2 args"; return 1}
	diff <(print -r "$1") <(print -r "$2")
}

alias pinge='ping www.example.com -c10'

################################################################################

## For highlighting
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[comment]='fg=240'

################################################################################


function -- -x { typeset +g -x SampShell_XTRACE=1; set -x; "$@" }
compdef -- _precommand -x

asciibytes=${(#j[]):-{0..127}}
allbytes=$asciibytes$'\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8A\x8B\x8C\x8D\x8E\x8F\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9A\x9B\x9C\x9D\x9E\x9F\xA0\xA1\xA2\xA3\xA4\xA5\xA6\xA7\xA8\xA9\xAA\xAB\xAC\xAD\xAE\xAF\xB0\xB1\xB2\xB3\xB4\xB5\xB6\xB7\xB8\xB9\xBA\xBB\xBC\xBD\xBE\xBF\xC0\xC1\xC2\xC3\xC4\xC5\xC6\xC7\xC8\xC9\xCA\xCB\xCC\xCD\xCE\xCF\xD0\xD1\xD2\xD3\xD4\xD5\xD6\xD7\xD8\xD9\xDA\xDB\xDC\xDD\xDE\xDF\xE0\xE1\xE2\xE3\xE4\xE5\xE6\xE7\xE8\xE9\xEA\xEB\xEC\xED\xEE\xEF\xF0\xF1\xF2\xF3\xF4\xF5\xF6\xF7\xF8\xF9\xFA\xFB\xFC\xFD\xFE\xFF'

################################################################################
# Random misc utils from work laptop. not sure how useful they are, or how tested.
################################################################################
alias show-cursor='tput cnorm'

# Check if in git repo
is-in-a-git-repo () (
	(( $+1 )) && cd -q $1
	git rev-parse --is-inside-work-tree >&/dev/null
)

# prints an associative array
prA () {
	emulate -L zsh
	local opts=()
	if [[ -n $NO_COLOR || ! -t 1 ]] opts+=(-c -M)
	for k v ( ${(@kvP)1} ) opts+=( --arg "$k" "$v" )
	jq -n '$ARGS.named' "${opts[@]}"
}
