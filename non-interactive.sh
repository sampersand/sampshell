export SampShell_HOME="${SampShell_HOME:-"$HOME/.sampshell"}"

export PATH="$SampShell_HOME/bin:$PATH"

export SampShell_EDITOR=sublime4

SampShell_isalias () {
	alias "${1?}" >/dev/null 2>&1
}

