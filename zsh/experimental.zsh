[ -z "$SampShell_experimental" ] && return

setopt MAGIC_EQUAL_SUBST # `a=b` does expansions
setopt CASE_GLOB # ?
setopt BRACE_CCL # Enable `{a-z}` and stuff
setopt C_BASES   # ?
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
