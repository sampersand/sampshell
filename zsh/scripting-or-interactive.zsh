## Enable debug mode.
alias debug=SampShell_debug
alias undebug=SampShell_undebug

## Default options that really should be enabled. 
setopt BAD_PATTERN     # bad patterns error out
setopt NOMATCH         # non-matching globs error out.
setopt EQUALS          # Do `=` expansion
setopt GLOB            # Why wouldnt you
setopt NO_{IGNORE_BRACES,IGNORE_CLOSE_BRACES} # make `a () { b }` valid.
setopt SHORT_LOOPS     # I use this semi-frequently
