## Shorthand for functions to ensure that the right arguments are given. It's an alias
# so it shoudl be the first thing. Example:
#	gs () ARGC_EXACTLY_0 git status
() {
	local i
	for i in {0..9}; do
		alias ARGC_EXACTLY_$i='${${$(((#=='$i'))&&print x):?exactly '$i' args needed}:#*} '
		alias ARGC_AT_MOST_$i='${${$(((#<='$i'))&&print x):?at most '$i' args needed}:#*} '
	done
}
