
# Set options
setopt AUTO_CD           # You just jsut type the dirname of something to change to it.
setopt AUTO_PUSHD        # All `cd`s push directories
setopt CHASE_LINKS       # Always resolve paths as their absolute paths.
setopt CDABLE_VARS       # Able to cd to directory vars
setopt PUSHD_SILENT      # pushd no longer prints things out; So annoying, just use `dir` if needed
setopt PUSHD_IGNORE_DUPS # don't put multiple of the same dir on the stack
# setopt AUTO_NAME_DIRS  # kinda iffy, cds to any variable

function cd () builtin cd ${@:--}
