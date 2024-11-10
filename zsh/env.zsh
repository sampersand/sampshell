typeset -Uxg path # make sure `path` is unique, and then export it

path+=(${0:P:h}/bin)

for file in "${0:P:h}"/non-interactive/*.zsh; do
	source $file
done

setopt EXTENDED_GLOB          # Add additional glob syntax in zsh
setopt NO_IGNORE_CLOSE_BRACES # Allow `}` to also be a `;`
setopt GLOB_STAR_SHORT        # **.c is an alias for **/*.c
false && setopt NO_ALIAS_FUNC_DEF MARK_DIRS noMULTI_FUNC_DEF # do we want no multi fn?
setopt NO_GLOB_ASSIGN # `a=*` won't expand out the `*
false && setopt warn_create_global warn_nested_var
