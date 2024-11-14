## Options I'm not sure if I want to set or not.
emulate sh -c '. "${(e)ENV}"'

setopt CORRECT           # Correct commands when executing.
setopt RM_STAR_WAIT      # Wait 10 seconds before accepting the `y` in `rm *`
setopt CSH_JUNKIE_LOOPS  # Allow loops to end in `end`; only loops tho not ifs

. ${0:P:h}/todo.zsh
