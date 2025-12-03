

# Convert base-10 integers to other bases
function d2h { __deprecated; bc --ibase=10 --obase=16 -e${(U)^@:?need something to convert} }
function d2o { __deprecated; bc --ibase=10 --obase=8  -e${(U)^@:?need something to convert} }
function d2b { __deprecated; bc --ibase=10 --obase=2  -e${(U)^@:?need something to convert} }

function h2d { __deprecated; bc --ibase=16 --obase=10 -e${(U)^@:?need something to convert} }
function h2o { __deprecated; bc --ibase=16 --obase=8  -e${(U)^@:?need something to convert} }
function h2b { __deprecated; bc --ibase=16 --obase=2  -e${(U)^@:?need something to convert} }

function o2h { __deprecated; bc --ibase=8 --obase=16  -e${(U)^@:?need something to convert} }
function o2d { __deprecated; bc --ibase=8 --obase=10 -e${(U)^@:?need something to convert} }
function o2b { __deprecated; bc --ibase=8 --obase=2  -e${(U)^@:?need something to convert} }

function b2h { __deprecated; bc --ibase=2 --obase=16  -e${(U)^@:?need something to convert} }
function b2d { __deprecated; bc --ibase=2 --obase=10 -e${(U)^@:?need something to convert} }
function b2o { __deprecated; bc --ibase=2 --obase=8  -e${(U)^@:?need something to convert} }


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
