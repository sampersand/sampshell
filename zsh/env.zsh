. ${0:P:h}/old/env.zsh

[[ -n $SampShell_TRACE ]] && setopt XTRACE VERBOSE

if [[ -n $SampShell_myscript ]]; then
	setopt WARN_CREATE_GLOBAL
	setopt WARN_NESTED_VAR
	setopt NO_GLOBAL_EXPORT
	setopt NO_ALIASES # dont setup aliases for my own scripts
	setopt NO_ALIAS_FUNC_DEF
	setopt NO_MULTI_FUNC_DEF # just use `function x y z { ... }`
fi

## 16.2.3 Expansion and Globbing
setopt BAD_PATTERN     # DEFAULT; bad patterns error out
setopt NOMATCH         # DEFAULT; non-matching globs error out.
setopt EQUALS          # DEFAULT; Do `=` expansion
setopt EXTENDED_GLOB   # Always have extended globs without needing to set it
setopt GLOB            # DEFAULT; Why wouldnt you
setopt GLOB_STAR_SHORT # Shorthand of `**.c`
setopt NO_{IGNORE_BRACES,IGNORE_CLOSE_BRACES} # DEFAULT; make `a () { b }` valid.

## 16.2.6 Input/Output
setopt RC_QUOTES # let you do `''` within `'`s to put single quotes
setopt SHORT_LOOPS # DEFAULT; I use this semi-frequently

