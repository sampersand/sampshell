setopt AUTO_PUSHD        # All `cd`s push directories
setopt CDABLE_VARS       # Able to cd to directory vars
setopt PUSHD_SILENT      # pushd no longer prints things out; So annoying, just use `dir` if needed
# setopt AUTO_NAME_DIRS  # kinda iffy, cds to any variable

## Setup named directory system
function add-named-dir {
	if [[ $1 = -h || $1 = --help ]]; then
		echo "usage: $0 [name=basename(dir)] [dir=PWD]" >&2
		return -1
	fi

	local dir=${2:-${1:-$PWD}}
	local name=${${1:-$dir}:t}

	builtin hash -d $name=$dir
}

function del-named-dir  {
	builtin unhash -d ${1:-${PWD:t}}
}

function dirs {
	builtin dirs ${@:--v} 
}
