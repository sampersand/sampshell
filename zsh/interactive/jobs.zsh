## Set options for jobs
setopt BG_NICE            # all background jobs run at the same nice level
setopt CHECK_JOBS         # Do not exit shells when there are still suspended jobs
setopt CHECK_RUNNING_JOBS # Also check for running jobs
setopt HUP                # hangup jobs when you're done; dont let them just exist

alias parallelize-it=parallelize_it
alias parallelize-it-skip=parallelize_it_skip

typeset -H SampShell_paralleize_it_skip_string # this doesn't need to be visible
