# Things in this file might eventually be subsumed into `zsh`

## Command line
setopt INTERACTIVE_COMMENTS # I use this all the time
setopt RC_QUOTES            # Let you do '' to mean a single `'` within a `'` string
setopt MAGIC_EQUAL_SUBST    # Supplying `a=b` on the command line does `~`/`=` expansion
setopt BANG_HIST            # Lets you do `!!` and friends

## Inline history stuff
histchars[2]=, # because `^` is a pain

## Autocompletion
setopt AUTO_PARAM_KEYS      # The character added after autocomplete can be autodeleted
setopt AUTO_REMOVE_SLASH    # same with trailing `/`
echo 'todo: autocompletion'

## Report times of commands that go long (cpu-wise); if it's unset then default to 5s.
: ${REPORTTIME=5}

