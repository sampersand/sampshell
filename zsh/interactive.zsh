# TODO: make sure the "use posix $0" is not set when it's not around

for file in "${SampShell_ROOTDIR:-${0:A:h}}"/zsh/interactive/*.zsh; do
	source $file
done

setopt INTERACTIVE_COMMENTS # I use comments in interactive shells often.
REPORTTIME=3 # anything that takes more than 3s of cpu time is reported
false && TIMEFMT=123
# REPORTMEMORY=

## Things to get used to
setopt MAGIC_EQUAL_SUBST    # Expand `~` and `=` after `=`s in arguments, eg `foo=~/ls`
setopt RC_QUOTES            # `''` in single quotes is interpreted as `'`
histchars[2]=,

## Others
setopt BAD_PATTERN # This is crazy not to have lol
# setopt UNSET WARN_CREATE_GLOBAL WARN_NESTED_VAR # For debugging
