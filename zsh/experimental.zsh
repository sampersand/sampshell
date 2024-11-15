## Options I'm not sure if I want to set or not.
[[ -n $ENV ]] && emulate sh -c '. "${(e)ENV}"'

setopt CORRECT              # Correct commands when executing.
setopt RM_STAR_WAIT         # Wait 10 seconds before accepting the `y` in `rm *`
setopt CSH_JUNKIE_LOOPS     # Allow loops to end in `end`; only loops tho not ifs
setopt CASE_GLOB CASE_PATHS # Enable case-insensitive globbing, woah!

## Defaults that probably shoudl eb set
unsetopt IGNORE_EOF      # In case it was set, as I use `ctrl+d` to exit a lot.

## 
TMPPREFIX=$SampShell_TMPDIR/.zsh/ # todo; shoudl this be set to SampShell_TMPDIR?


. ${0:P:h}/todo.zsh
