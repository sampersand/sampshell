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

## Repeats a string
function xx {
	
	repeat ${2:?need a count} print -rn -- ${1:?need a string}
	print
}

alias banner='noglob ~ss/bin/banner' # noglob's so that we can just give most strings
function b80  { banner -w80 $@  | pbcopy }
function b100 { banner -w100 $@ | pbcopy }
