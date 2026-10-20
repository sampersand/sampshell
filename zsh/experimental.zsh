## Options I'm not sure if I want to set or not.
# [[ -n $ENV ]] && emulate sh -c '. "${(e)ENV}"' # <-- TODO, do we want ENV

: "${REPORTTIME:=4}" # Print the duration of commands that take more than 4s of CPU time

setopt EXTENDED_HISTORY     # (For fun) When writing cmds, write their start time & duration too.
setopt COMPLETE_IN_WORD
setopt CORRECT                 # Correct commands when executing.
setopt NO_CASE_GLOB CASE_PATHS # Enable case-insensitive globbing, woah!

CORRECT_IGNORE='(_*|[^[:space:]]# \(\))' # Don't correct to functions starting with `_`

: command_not_found_handler # <-- thing executed when a command's not found

### Saving and restoring dirstack
DIRSTACKSIZE=20
setopt PUSHD_IGNORE_DUPS # eh, let's see if it works?
# () { setopt LOCAL_OPTIONS NO_AUTO_PUSHD PUSHD_SILENT; dirs -c; source ~/.cshdirs }
# zshexit() { dirs -pl | tac | sed '1s/^/cd /; 2,$s/^/pushd /' >! ~/.cshdirs }
# () {
# 	dirs -c $(cat ~/.zshdirs)
# 	popd -q
# 	setopt LOCAL_OPTIONS NO_AUTO_PUSHD PUSHD_SILENT; dirs -c; source ~/.cshdirs
# }
: ${SampShell_ZSHDIRS:=$SampShell_STATE_HOME/.zshdirs}
if [[ -e $SampShell_ZSHDIRS ]] then
	dirs -c ${(f)"$(< $SampShell_ZSHDIRS)"}
	popd -q # remove the current directory from the base of the stack
fi
dirs-write () {
	if [[ $HISTFILE ]] {
		mkdir -p $SampShell_ZSHDIRS:h && dirs -pl >| $SampShell_ZSHDIRS
	}
}
add-zsh-hook zshexit dirs-write
