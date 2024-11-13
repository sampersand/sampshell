# TODO: make sure the "use posix $0" is not set when it's not around

# emulate sh -c '. "${(e)ENV}"'

for file in "${SampShell_ROOTDIR:-${0:A:h}}"/zsh/old/interactive-files/*.zsh; do
	source $file
done

## Others
setopt BAD_PATTERN # This is crazy not to have lol

# [[ -n $SampShell_TMPDIR ]] && add-named-dir tmp $SampShell_TMPDIR
# add-named-dir d ~/Desktop
# add-named-dir dl ~/Downloads
# add-named-dir ss $SampShell_ROOTDIR

function debug {
	if [[ $# = 0 ]]; then
		SampShell_VERBOSE=1 SampShell_TRACE=1 $@
	else
		SampShell_debug
	fi
}
alias debug=SampShell-debug
alias undebug=SampShell-undebug

#---
setopt HIST_SUBST_PATTERN
echo 'todo: HIST_SUBST_PATTERN'
setopt MAGIC_EQUAL_SUBST

setopt NO_UNSET # I use this fairly frequently
