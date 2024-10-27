## Command line
setopt INTERACTIVE_COMMENTS # I use this all the time
setopt RC_QUOTES            # Let you do '' to mean a single `'` within a `'` string
setopt PROMPT_CR            # Put a `\n` before so you dont get the newline ickiness with no-newlines
setopt MAGIC_EQUAL_SUBST    # Supplying `a=b` on the command line does `~`/`=` expansion

## Autocompletion
setopt AUTO_PARAM_KEYS      # The character added after autocomplete can be autodeleted
setopt AUTO_REMOVE_SLASH    # same with trailing `/`
echo 'todo: autocompletion'

## Options I don't want set
setopt NO_AUTO_CD           # You have to actually `cd` into a directory to change.
setopt NO_RM_STAR_SILENT    # Don't let `*` do dumb stuff
setopt NO_SHARE_HISTORY     # Dont' sahre history between shell invocations?
setopt HIST_IGNORE_ALL_DUPS # If we have all the commands, we can see the frequency at which they're used.
setopt RM_STAR_WAIT         # Ensure accidental rm * will wait

echo 'todo: INC_APPEND_HISTORY'
setopt NO_KSH_GLOB # ???
setopt INC_APPEND_HISTORY # TODO?
