### Job Control
# This file is for config relating to jobs in ZSH.
###

## Enable options
setopt MONITOR            # Enable job control, in case it's not already sent
setopt AUTO_CONTINUE      # Always sent `SIGCONT` when disowning jobs, so they run again.
setopt CHECK_JOBS         # Confirm before exiting the shell if there's suspended jobs
setopt CHECK_RUNNING_JOBS # Same as CHECK_JOBS, but also for running jobs.
setopt HUP                # When the shell closes, send SIGUP to all jobs.

## Create the shorthand for `parallelize-it`
parallelize-it () SampShell_parallelize_it $@

## Experimental changes
if [[ -n $SampShell_experimental ]]; then
	# setopt BG_NICE # <-- we don't have much of an opinion on this.
	setopt AUTO_RESUME # Single words can be used to resume commands; IDK how useful this is
	setopt LONG_LIST_JOBS # long-format; do i need this?
	setopt NOTIFY # Immediately report when jobs are done, instead of waiting. I'm not sure whether i want to wait or not, so that's why this is here.
fi
