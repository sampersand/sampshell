# Set options
setopt AUTO_PUSHD        # All `cd`s push directories
setopt CHASE_LINKS       # Always resolve paths as their absolute paths.
setopt CDABLE_VARS       # Able to cd to directory vars
setopt PUSHD_SILENT      # pushd no longer prints things out; So annoying, just use `dir` if needed
setopt PUSHD_IGNORE_DUPS # don't put multiple of the same dir on the stack

# setopt AUTO_NAME_DIRS  # kinda iffy, cds to any variable

## Setup named directory system
function {SampShell-,}add-named-dir {
	if [[ $1 = -h || $1 = --help ]]; then
		echo "usage: $0 [name=basename(dir)] [dir=PWD]"
		return 0
	fi

	local dir=${2:-${1:-$PWD}}
	local name=${${1:-$dir}:t}

	builtin hash -d $name=$dir
}

function {SampShell-,}del-named-dir  {
	builtin unhash -d ${1:-${PWD:t}}
}

function dirs {
	builtin dirs ${@:--v} 
}
