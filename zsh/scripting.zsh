## Options I want enabled for scripts I write. This should be sourced at the top of every script
# im thinking of removing this

## include the interactive-or-scripting config, ie stuff we don't want for _all_ scripts, but just
# sampshell scripts.
source ${0:P:h}/scripting-or-interactive.zsh

unalias SampShell-script # Should only be set once per script, so no reason to keep it around.

typeset -g +x SampShell_scripting=1 # used within `undebug`

## Enable "guardrails". These provide sanity checks
setopt WARN_CREATE_GLOBAL # Warn when an assignment in a function creates a global variable
setopt WARN_NESTED_VAR    # Warn when an assignment to a function clobbers an enclosing one.
setopt NO_GLOBAL_EXPORT   # `typeset -x foo` no longer makes variables global.
setopt NO_UNSET           # Unset variables are errors
setopt NO_ALIASES         # Do not use aliases at all.
setopt NO_ALIAS_FUNC_DEF  # `alias a=b; a () ...`  will still define the function `a`, not `b`.
setopt NO_MULTI_FUNC_DEF  # Disables `a b c () { ... }`; use `function x y z { ... }` instead.
