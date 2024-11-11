[ -z "$SampShell_experimental" ] && return

setopt AUTO_CD # you can cd with filenames

setopt LONG_LIST_JOBS # long form description for jobs when exiting
# setopt PRINT_EXIT_VALUE # print exit value for commands; nope, because it prints out for bad commands too
setopt CASE_GLOB # ?
setopt C_BASES   # ?
setopt MARK_DIRS
# setopt NUMERIC_GLOB_SORT
# setopt SOURCE_TRACE # for debugging

## under-used, but still want them
alias pwc='current-commit'
alias pwb='current-branch'
alias mbr='master-branch'

alias grep='grep --color=auto'

# Gets the current branch (ISH---this isn't working)
function git-current-branch () git rev-parse --abbrev-ref HEAD

# Returns zero or nonzero depending on when on if it's in a repo.
function is-in-a-git-repo () git rev-parse --is-inside-work-tree >&- 2>&-

gremove-remote () {
	echo "not tested" && return
	git branch -d | xargs -L1 git branch -Dr
}
