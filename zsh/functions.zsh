# Convert base-10 integers to other bases
function d2h { bc --ibase=10 --obase=16 -e${(U)^@:?need something to convert} }
function d2o { bc --ibase=10 --obase=8  -e${(U)^@:?need something to convert} }
function d2b { bc --ibase=10 --obase=2  -e${(U)^@:?need something to convert} }

function h2d { bc --ibase=16 --obase=10 -e${(U)^@:?need something to convert} }
function h2o { bc --ibase=16 --obase=8  -e${(U)^@:?need something to convert} }
function h2b { bc --ibase=16 --obase=2  -e${(U)^@:?need something to convert} }

function o2h { bc --ibase=8 --obase=16  -e${(U)^@:?need something to convert} }
function o2d { bc --ibase=8 --obase=10 -e${(U)^@:?need something to convert} }
function o2b { bc --ibase=8 --obase=2  -e${(U)^@:?need something to convert} }

function b2h { bc --ibase=2 --obase=16  -e${(U)^@:?need something to convert} }
function b2d { bc --ibase=2 --obase=10 -e${(U)^@:?need something to convert} }
function b2o { bc --ibase=2 --obase=8  -e${(U)^@:?need something to convert} }

# Adds in "clean shell" aliases, which startup a clean version of shells, and only set "normal"
# vars such as $TERM/$HOME etc. Relies on my `clean-shell` function being in `$PATH`.
alias   clsh='clean-shell sh'
alias clbash='clean-shell bash'
alias  clzsh='clean-shell zsh'
alias cldash='clean-shell dash'

## Banner utility
alias banner='noglob ~ss/bin/universal/banner'
alias b80='banner -c -w80'
alias b100='banner -c -w100'

## Debugging utilities
function -x {
	typeset +g -x SampShell_XTRACE=1
	set -x
	"$@"
}

function pa {
	local a b i=0
	if [[ ${(tP)1} = array-* ]]; then
		p ${(P)1}
	else
		for a b in ${(kvP)1}; do
			printf "%3d: %-20s%s\n" $((i++)) $a $b
		done
	fi
}
## Adding default arguments to builtin commands
function grep () grep --color=auto $@
alias ps='ps -ax'

################################################################################
#                                Math Functions                                #
################################################################################

# Functions for shell math; these can be used in any arithmetic contexts (incl.
# eg indexing into arrays). The return value is the return value of the last
# math operation done in the function. (Which also means the return value must
# be `true` not `return 0`, as `return`'s argument is a math op.)

# NOTE: `autoload zmathfunc; zmathfunc` will define `min` and `max`, however
# it's much less efficient than these are (i think?)
function SampShell-math-min  { (( ${${(-)@#+}[1]} )); true }
function SampShell-math-max  { (( ${${(-)@#+}[-1]} )); true }
function SampShell-math-cmp  { (( sign($1 - $2) )); true }
function SampShell-math-sign { (( $1 < 0 ? -1 : $1 > 0 )); true }
function SampShell-math-rand { (( $(SampShell-randint $@) )); true }

# functions -M <math name> <min argc> <max argc> <shell fn name>
functions -M  min 1 -1 SampShell-math-min
functions -M  max 1 -1 SampShell-math-max
functions -M  cmp 2  2 SampShell-math-cmp
functions -M sign 1  1 SampShell-math-sign
functions -M rand 0  2 SampShell-math-rand

function {SampShell-,}randint {
	local min max
	if (( $# == 2 )) then
		min=$1 max=$2
	else
		min=0 max=${1:-9223372036854775807}
	fi
	shuf --random-source=/dev/urandom -n 1 -i $min-$max
	# `shuf` isn't posix compliant, but the following is:
	# od -vAn -N8 -tu8 < /dev/urandom | tr -d ' ' 
}
