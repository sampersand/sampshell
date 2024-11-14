## Options I want enabled for scripts I write. This should be sourced at the top of every script
# im thinking of removing this

## include the interactive-or-scripting config, ie stuff we don't want for _all_ scripts, but just
# sampshell scripts.
unalias SampShell-script # Should only be set once per script, so no reason to keep it around.

## Enable "guardrails". These provide sanity checks
setopt WARN_CREATE_GLOBAL # Warn when an assignment in a function creates a global variable
setopt WARN_NESTED_VAR    # Warn when an assignment to a function clobbers an enclosing one.
unsetopt GLOBAL_EXPORT    # `typeset -x foo` no longer makes variables global.
unsetopt UNSET            # Unset variables are errors
unsetopt ALIASES          # Do not use aliases at all.
unsetopt ALIAS_FUNC_DEF   # `alias a=b; a () ...`  will still define the function `a`, not `b`.
unsetopt MULTI_FUNC_DEF   # Disables `a b c () { ... }`; use `function x y z { ... }` instead.
unsetopt GLOB_ASSIGN      # `a=*` sets `a` to `*` (ie doesnt expand). That's the default behaviour.

## Enable options that might have been disabled for some bizarre reason
setopt SHORT_LOOPS  # Allow short-forms
unsetopt GLOB_SUBST # when set, requires quoting everything like bash

## Todo, should this always be used?
[[ -n $SampShell_experimental ]] && hash -d ss=$SampShell_ROOTDIR
