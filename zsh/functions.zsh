################################################################################
#                                 Conversions                                  #
################################################################################

# Convert base-10 integers to other bases
function hex { bc -O16 -e$^@ }
function oct { bc  -O8 -e$^@ }
function bin { bc  -O2 -e$^@ }

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
function xx { repeat $2 print -rn -- $1; print } # Repeats a string

# alias banner='noglob ~ss/bin/banner' # Annoying cause banner is a builtin on macos
# b80 () { banner "$@" | pbcopy }
# b100 () { banner -w100 "$@" | pbcopy }
