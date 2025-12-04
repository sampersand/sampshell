## Stuff in `.zshrc` which I used to have set, but don't need anympore
unsetopt NO_MONITOR            # Enable job control, in case it's not already sent

# I never end up doing this, so no need to set it up
setopt AUTO_CD # Enables `dir` to be shorthand for `cd dir` if `dir` isn't a valid cmd

# Experimental, see if I actually need this.
setopt PUSHD_IGNORE_DUPS # Delete duplicate entries on the dir stack when adding new ones.

# I don't find myself doing this _that_ often, and it makes `>|/dev/null` which is weird.
setopt HIST_ALLOW_CLOBBER   # Add `|` to `>` and `>>`, so that re-running the command can clobber.

## these are now scripts:

# Removedir and mkdir aliases. Only removes directories with `.DS_Store` in them
# rd () { command rm -f -- ${1:?need a dir}/.DS_Store && command rmdir -- $1 }
# md () { command mkdir -p -- "${1:?missing a directory}" && command cd -- "$1" }

# utility functions and what have you that I've accumulated over the years
false && chr () ruby -- /dev/fd/3 $@ 3<<'RUBY'
puts ([]==$*?$stdin.map(&:chomp):$*).map{|w|w.bytes.map{_1.to_s 16}.join(?\s)}
RUBY
# $*.empty? and $*.replace $stdin.map(&:chomp)
# puts $*.map{|w|w.bytes.map{|b|b.to_s 16}.join(?\s)}

false && ord () ruby -- /dev/fd/3 $@ 3<<'RUBY'
puts ($*.empty? ? $stdin.map{_1.chomp.split} : [$*])
	.map{_1.map(&:hex).pack('C*')}
RUBY

## These are now keybinds:
# Copies a previous command
cpcmd () { print -r -- $history[$((HISTCMD-${1:-1}))] | pbc }
copycmd () { print -r $history[$(($#history - 0))] | pbc; }
prl () print -zr -- $ZLE_LINE_ABORTED
cpc () { print -r -- $history[${1:-$#history}] | tee "$(tty)" | pbc }

# `md` now used
alias mk=mkdir

# TODO: Figure out howto get `s` and `ss` to also accept things like CDPATH and `CDABLE_VARS` opts.
s2 ()  (cd -q -- $@ >/dev/null && subl -- "$PWD")
ss2 () (cd -q -- $@ >/dev/null && subl --create -- "$PWD")

# This doesn't even exist anymore
alias parallelize-it=parallelize_it ## Create the shorthand for `parallelize-it`; TODO: do we stillw ant that
