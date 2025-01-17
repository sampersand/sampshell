

## Options for the prompting
setopt PROMPT_SUBST        # Lets you use variables and $(...) in prompts.
unsetopt NO_PROMPT_PERCENT # Ensure `%` escapes in prompts are enabled.
unsetopt PROMPT_BANG       # Don't make `!` mean history number; we do this with %!.
unsetopt NO_PROMPT_{CR,SP} # Ensure a `\r` is printed before a line starts
setopt TRANSIENT_RPROMPT   # Remove RPS1 when a line is accepted. (Makes it easier to copy stuff.)

## Special ZSH variable that is printed after we enter a command; We use it to make sure we reset
# the colouring in case the prompt gets screwed up somehow
POSTEDIT=$(print -nP %b%u%s%f)

# source ${0:P:h}/fix-spaces-after-eol-mark-macos.zsh

# Mark `PS1` and `RPS1` as global, but not exported, so other shells don't inherit them.
typeset -g +x PS1 RPS1

source ${0:P:h}/ps1.zsh
source ${0:P:h}/rps1.zsh

eval "c () { source ${(q)0:P} && SampShell-create-prompt }"
