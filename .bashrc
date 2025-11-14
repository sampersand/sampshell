. "$SampShell_ROOTDIR/.shrc"

if [[ -z "$PS1" ]]; then
	PS1='[?$? !\! L$SHLVL] ${PWD#"${HOME%/}"/} ${0##*/}$ '
fi

if [[ "$(uname)" = Darwin ]]; then
	BASH_SILENCE_DEPRECATION_WARNING=1
fi
