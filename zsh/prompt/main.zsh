source ${0:P:h}/fix-spaces-after-eol-mark-macos.zsh
source ${0:P:h}/prompt-widgets.zsh
make-ps1
unfunction make-prompt
# Create the prompt with default values
source ${0:P:h}/ps1.zsh


## Special ZSH variable that is printed after we enter a command; We use it to make sure we reset
# the colouring in case the prompt gets screwed up somehow
POSTEDIT=$(print -nP %b%u%s%f)
