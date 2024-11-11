. ${0:P:h}/old/env.zsh

[[ -n $SampShell_TRACE ]] && setopt XTRACE VERBOSE

setopt RC_QUOTES
setopt NO_ALIAS_FUNC_DEF
setopt EXTENDED_GLOB
setopt GLOB_STAR_SHORT

setopt FUNCTION_ARGZERO # Set `$0` to the name of a function/script


if [[ -n $SampShell_clean_script ]]; then
	setopt LOCAL_LOOPS # break/continue cannot propagate outside their fns. I think.
	setopt NO_MULTI_FUNC_DEF # just use `function`
fi
