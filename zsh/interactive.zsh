# TODO: make sure the "use posix $0" is not set when it's not around

for file in "${SampShell_ROOTDIR:-${0:A:h}}"/zsh/interactive/*.zsh; do
	source $file
done

setopt INTERACTIVE_COMMENTS # I use comments in interactive shells often.

## Things to get used to
setopt MAGIC_EQUAL_SUBST    # Expand `~` and `=` after `=`s in arguments, eg `foo=~/ls`
setopt RC_QUOTES            # `''` in single quotes is interpreted as `'`

## Others
