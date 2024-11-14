## Options I want enabled for scripts I write. This should be sourced at the top of every script
# im thinking of removing this

## include the interactive-or-scripting config, ie stuff we don't want for _all_ scripts, but just
# sampshell scripts.
unalias SampShell-script # Should only be set once per script, so no reason to keep it around.

## Enable "guardrails". These provide sanity checks, mostly. I should probs separate them out.
# (I've structured this such that `setopt XXX` are setting values, whereas `unsetopt` are disabling
# ones that might've been set already. that's why `unsetopt no_xxx` might appear.)
setopt WARN_CREATE_GLOBAL # Warn when an assignment in a function creates a global variable
setopt WARN_NESTED_VAR    # Warn when an assignment to a function clobbers an enclosing one.
setopt NO_ALIASES         # Do not use aliases at all when scripting. 
setopt NO_MULTI_FUNC_DEF  # Disables `a b c () { ... }`; use `function x y z { ... }` instead.
unsetopt NOMATCH          # Print an error if globbing fails, instead of silently just leaving it.
unsetopt GLOBAL_EXPORT    # `typeset -x foo` no longer makes variables global.
unsetopt UNSET            # Unset variables are errors
unsetopt ALIAS_FUNC_DEF   # `alias a=b; a () ...`  will still define the function `a`, not `b`.
unsetopt GLOB_ASSIGN      # `a=*` sets `a` to `*` (ie doesnt expand). That's the default behaviour.
unsetopt GLOB_SUBST       # When set, requires quoting everything like bash
unsetopt NO_SHORT_LOOPS   # Allow short-forms of loops
unsetopt NO_BAD_PATTERN   # Bad patterns error out, instead of silently being left around.
unsetopt NO_EQUALS        # Do `=` expansion
unsetopt NO_GLOB          # Enable globbing
unsetopt NO_SHORT_LOOPS   # I use this semi-frequently
setopt RC_QUOTES          # Let you do type `''` within single quotes, eg `'let''s go, friend!'`
unsetopt IGNORE_BRACES IGNORE_CLOSE_BRACES # make `a () { b }` valid.

## Todo, should this always be used? or even be here?
[[ -n ${SampShell_experimental-} ]] && hash -d ss=$SampShell_ROOTDIR
