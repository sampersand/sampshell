## Command line
setopt INTERACTIVE_COMMENTS # I use this all the time
setopt RC_QUOTES            # Let you do '' to mean a single `'` within a `'` string
setopt PROMPT_CR            # Put a `\n` before so you dont get the newline ickiness with no-newlines
setopt MAGIC_EQUAL_SUBST    # Supplying `a=b` on the command line does `~`/`=` expansion

## Autocompletion
setopt AUTO_PARAM_KEYS      # The character added after autocomplete can be autodeleted
setopt AUTO_REMOVE_SLASH    # same with trailing `/`
echo 'todo: autocompletion'
