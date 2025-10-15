## Options I'm not sure if I want to set or not.
# [[ -n $ENV ]] && emulate sh -c '. "${(e)ENV}"'

: "${REPORTTIME=4}" # Print the duration of commands that take more than 4s of CPU time
# DIRSTACKSIZE=30   # I just started using dirstack more, if it ever grows unwieldy I can set this.

setopt EXTENDED_HISTORY     # (For fun) When writing cmds, write their start time & duration too.
setopt COMPLETE_IN_WORD
setopt CORRECT              # Correct commands when executing.
# setopt RM_STAR_WAIT       # Disabled, since I don't need this level of protection. Wait 10 seconds before accepting the `y` in `rm *`
setopt CASE_GLOB CASE_PATHS # Enable case-insensitive globbing, woah!
# setopt NO_FLOW_CONTROL    # Modern terminals dont need control flow lol (?? whats this even do?)

# WORDCHARS=$WORDCHARS # ooo, you can modify which chars are for a word in ZLE
CORRECT_IGNORE='(_*|[^[:space:]]# \(\))' # Don't correct to functions starting with `_`
# CORRECT_IGNORE_FILE ; setopt correct_all

## Defaults that probably shoudl eb set
unsetopt GLOB_SUBST SH_GLOB # defaults that should be set

: command_not_found_handler # <-- thing executed when a command'snot found
### Completion
# setopt MENU_COMPLETE

