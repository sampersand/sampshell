# p () {
# 	SampShell_scratch=0
# 	# inspect <>3

# 	while [ "$#" -ne 0 ]; do
# 		# Can't put in next line b/c the `| dump` forks
# 		: "$(( SampShell_scratch += 1 ))"

# 		if ! printf '%5d: %s\n' "$SampShell_scratch" "$1"; then
# 			unset -v SampShell_scratch
# 			return 1
# 		fi

# 		shift
# 	done | inspect
# 	unset -v SampShell_scratch
# }
