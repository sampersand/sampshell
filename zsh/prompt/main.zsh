source ${0:P:h}/fix-spaces-after-eol-mark-macos.zsh
source ${0:P:h}/reset-formatting-after-prompt.zsh
source ${0:P:h}/__old_prompt-format.zsh # TODO: clean this up
make-ps1
unfunction make-prompt
source ${0:P:h}/ps1.zsh

# Create the prompt with default values
