#!/bin/dash

# This file is sadly not POSIX-compliant, because POSIX doesn't define the `%q`
# specifier. Sad!

## Prints out its arguments in a debug format.

count=0
for argument; do
	printf "%5d: %s\n" "$(( count += 1 ))" "$argument"
done
