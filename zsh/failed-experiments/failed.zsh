####################################################################################################
#                                                                                                  #
#                                        Failed Experiments                                        #
#                                                                                                  #
####################################################################################################

setopt CSH_JUNKIE_LOOPS # Allow loops to end in `end`; only loops tho not ifs. also doesnt let short-formofthings
KEYBOARD_HACK=\' # ignore an odd-number of `'`s, but also on line continuation, ugh.

# Doesn't really seem to do anything extra beyond what the normal one does
PROMPT_EOL_MARK=$'\e[m'"%B%S%#%s%b"

## Not needed, now that I have `history-ignore-command`
HISTORY_IGNORE='(h|cmd2*)' # If set, don't write lines that match to the HISTFILE when saving.

## No real need to specify the temp directory, and in case TMPDIR doesnt exist, this fails.
TMPPREFIX=$TMPDIR/.zsh # todo; shoudl this be set to SampShell_TMPDIR?
