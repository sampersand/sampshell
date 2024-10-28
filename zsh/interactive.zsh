# TODO: make sure the "use posix $0" is not set when it's not around

for file in "${SampShell_ROOTDIR:-${0:A:h}}"/zsh/interactive/*.zsh; do
	source $file
done


## Others
setopt BAD_PATTERN # This is crazy not to have lol


[[ -n $SampShell_TMPDIR ]] && add-named-dir tmp $SampShell_TMPDIR
add-named-dir d ~/Desktop
add-named-dir dl ~/Downloads
add-named-dir ss ${SampShell_ROOTDIR?}
