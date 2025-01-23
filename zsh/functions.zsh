################################################################################
#                                 Conversions                                  #
################################################################################

# Convert base-10 integers to other bases
function hex { bc <(print -l obase=16 $@ quit) }
function oct { bc <(print -l obase=8 $@ quit) }
function bin { bc <(print -l obase=2 $@ quit) }

################################################################################
#                                 Other Shells                                 #
################################################################################

# Adds in "clean shell" functions, which startup a clean version of shells, and
# only set "normal" vars such as $TERM/$HOME etc
function clsh   { clean-shell --shell =sh   --none -- $@ }
function clbash { clean-shell --shell =bash --none -- --noprofile --norc $@ }
function clzsh  { clean-shell --shell =zsh  --none -- -fd $@ }
function cldash { clean-shell --shell =dash --none -- -l $@ }

################################################################################
#                                    others                                    #
################################################################################

## Helpful shorthand utilities
alias banner='noglob ~ss/bin/banner' # noglob's so that we can give most strings
function b80  { banner -w80 $@  | pbcopy }
function b100 { banner -w100 $@ | pbcopy }

################################################################################
#                                Math Functions                                #
################################################################################

# Functions for shell math; these can be used in any arithmetic contexts (incl.
# eg indexing into arrays). The return value is the return value of the last
# math operation done in the function. (Which also means the return value must
# be `true` not `return 0`, as `return`'s argument is a math op.)

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
