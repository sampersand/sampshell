## Command line
setopt INTERACTIVE_COMMENTS # I use this all the time
setopt RC_QUOTES            # Let you do '' to mean a single `'` within a `'` string
setopt MAGIC_EQUAL_SUBST    # Supplying `a=b` on the command line does `~`/`=` expansion

## Inline history stuff
histchars[2]=, # because `^` is a pain

## Autocompletion
setopt AUTO_PARAM_KEYS      # The character added after autocomplete can be autodeleted
setopt AUTO_REMOVE_SLASH    # same with trailing `/`
echo 'todo: autocompletion'

## Options that might be overwritten that I want changed.
setopt PROMPT_CR            # Put a `\n` before so you dont get the newline ickiness with no-newlines
setopt NO_AUTO_CD           # You have to actually `cd` into a directory to change.
setopt NO_RM_STAR_SILENT    # Don't let `*` do dumb stuff
setopt NO_SHARE_HISTORY     # Dont' sahre history between shell invocations?
setopt RM_STAR_WAIT         # Ensure accidental rm * will wait

## Report times of commands that go long (cpu-wise)
function SampShell-set-report-time {
	REPORTTIME="${1?}"
}

# If `REPORTTIME` is unset, then default it to 5 seconds
[[ ! -v REPORTTIME ]] && SampShell-set-report-time 5

