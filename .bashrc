. "$SampShell_ROOTDIR/.shrc"

PS1='[?$? !\! L$SHLVL] ${PWD#"${HOME%/}"/} ${0##*/}$ '
[[ "$(uname)" = Darwin ]] && BASH_SILENCE_DEPRECATION_WARNING=1
