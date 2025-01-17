## Options for the prompting
setopt PROMPT_SUBST        # Lets you use variables and $(...) in prompts.
unsetopt NO_PROMPT_PERCENT # Ensure `%` escapes in prompts are enabled.
unsetopt PROMPT_BANG       # Don't make `!` mean history number; we do this with %!.
unsetopt NO_PROMPT_{CR,SP} # Ensure a `\r` is printed before a line starts
setopt TRANSIENT_RPROMPT   # Remove RPS1 when a line is accepted. (Makes it easier to copy stuff.)

## Special ZSH variable that is printed after we enter a command; We use it to make sure we reset
# the colouring in case the prompt gets screwed up somehow
POSTEDIT=${(%):-%b%u%s%f}

# source ${0:P:h}/fix-spaces-after-eol-mark-macos.zsh

# Mark `PS1` and `RPS1` as global, but not exported, so other shells don't inherit them.
typeset -g +x PS1 RPS1

source ${0:P:h}/ps1.zsh
source ${0:P:h}/rps1.zsh

eval "c () { source ${(q)0:P} && SampShell-create-prompt }"

# The following are the zstyles that're used, and their defaults
if false; then
	# if `1`/`on`/`yes`/`true`, always display, if auto, do default as if it were unset. if
	# anything else, disable
	zstyle ':sampshell:prompt:*' display

	zstyle ':sampshell:prompt:time' format '%_I:%M:%S %p' # The time format

	zstyle ':sampshell:prompt:jobcount' display auto # true: always display. auto: only if > 0
	zstyle ':sampshell:prompt:shlvl'    display auto # true: always display. auto: only if > 1

	zstyle ':sampshell:prompt:userhost' display auto # true: always display. auto: dont display if expected equal
	zstyle ':sampshell:prompt:hostname' expected # not set by default; if it and username are set, and
	zstyle ':sampshell:prompt:username' expected # ..equal to the machine, nothing. if not, red & bold.

	zstyle ':sampshell:prompt:path' display # if set to `always`, display the full path. Unable to be disabled.
	zstyle ':sampshell:prompt:path' length $((COLUMNS * 2 / 5)) # length of paths before truncation

	zstyle ':sampshell:prompt:git' display auto # true: always display. auto: only if in a repo
	zstyle ':sampshell:prompt:git' pattern  # not set by default; if set, used when truncating repo paths.
	# zstyle ':sampshell:prompt:*' display 1

fi

ps1_header () {
	local sep='%F{blue}%B|%f%b'

	echo
	echo -n $sep "$(ruby --version | awk '{print $2}')" $sep '%F{11}%d' $sep ''
	echo -n %y $sep %n@%M $sep "$(_SampShell-prompt-current-battery)" $sep
}

# PS1+='$(typeset -f ps1_header >/dev/null && { ps1_header; print })'$'\n'
