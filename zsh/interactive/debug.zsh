function {SampShell-,}debug {
	setopt SOURCE_TRACE UNSET WARN_CREATE_GLOBAL WARN_NESTED_VAR 
}

function {SampShell-,}undebug {
	setopt NO_{SOURCE_TRACE,UNSET,WARN_CREATE_GLOBAL,WARN_NESTED_VAR}
}
