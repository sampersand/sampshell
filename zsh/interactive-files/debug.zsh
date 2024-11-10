function {SampShell-,}debug {
	setopt SOURCE_TRACE UNSET WARN_CREATE_GLOBAL WARN_NESTED_VAR
	export SampShell_TRACE=1
}

function {SampShell-,}undebug {
	setopt NO_{SOURCE_TRACE,UNSET,WARN_CREATE_GLOBAL,WARN_NESTED_VAR}
	unset SampShell_TRACE
}
