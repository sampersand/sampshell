## All this is experimental
alias bk='noglob bindkey'
alias bkg='bindkey | noglob fgrep -ie'

bindkey -N SampShell_keymap emacs
bindkey -A SampShell_keymap main

bindkey '^x^z' undo
bindkey '^xz' undo
bindkey Ω undo
bindkey ¥ redo

## Whenever we accept a line, make sure to remove trailing newlines
function SampShell-zle-accept-line { BUFFER=${(*)BUFFER%%$'\n'#}; zle .accept-line }
zle -N accept-line SampShell-zle-accept-line
# ^^ OMG this is amazing, it actually even affects enter

## Make `clear-screen` use the `cls` builtin
function SampShell-zle-clear-screen { cls && zle reset-prompt }
zle -N clear-screen SampShell-zle-clear-screen
bindkey '^L' clear-screen  # this is the default anyways

## Make `pound-insert` use the histchar character, and add a space too
function SampShell-zle-pound-insert { BUFFER="$histchars[3] $BUFFER"; zle accept-line }
zle -N pound-insert SampShell-zle-pound-insert
bindkey '^[/' pound-insert # comment a line out

## My own function; `strip-whitespace` deletes whitespace from the start and end of a line.
function SampShell-zle-strip-whitespace { BUFFER=${(*)${(*)BUFFER%%[[:space:]]#}##[[:space:]]#} }
zle -N strip-whitespace SampShell-zle-strip-whitespace
stty -ixon # make it so CTRL+S actually works
bindkey '^S' strip-whitespace

bindkey -s '^gs' '^Qgit status^M'
bindkey -s '^gaa' '^Qgit add --all^M'
bindkey -s '^[r' '^Qreload^M'


return

## Things to look use more


# `^[^?` deletes a word backwards from the cursor
# `^[^M` (ie escape+enter) adds a newline
# `^K` kills a line
# vi-match-bracket (^X^B) (%) (unbound), go to amatching bracket
# ^[' quotes the entire line in single ticks
## Default bindkeys that I really dont need, and can be used for something else
bindkey -r '^B' # same as left arrow
bindkey -r '^F' # same as right arrow
bindkey -r '^P' # same as up arrow
bindkey -r '^N' # same as down arrow 
bindkey -r '^H' # same as delete key (which is `^?`)
bindkey -r '^[C' -r '^[c' # capitalize the word them move beyond it. seems super useless.
bindkey -r '^[L' -r '^[l' # lowercase a word and move beyond it.
bindkey -r '^[U' -r '^[u' # uppercase a word and move beyond it.
bindkey -r '^X^O' # overwrite-mode; i hate this and never use it.
bindkey -r '^[?' # checks where the current command is. seems pretty useless imo
# bindkey -r '^S' # "history-incremental-search-forward""; replace this with down arrow eventually.
# bindkey -R 'beginning-of-buffer-or-history (ESC-<) (gg) (unbound)'

## TODOS
if false; then
WORDCHARS=#TODO what are words
quoted-insert (^V), inserts next character literally. how useful is that??

history-incremental-search-backward <-- see if you can also set up arrow to use this too
history-incremental-pattern-search-backward
history-incremental-pattern-search-forward <-- oo, uses pattern searches

# history-search-backward ^P, like history search, but uses the first word in the command buffer
# history-search-forward ^N, see above

insert-last-word, `^[_`and `^[.`, interesting.
copy-region-as-kil ^[W, copy a region? is this cmd+c?
copy-prev-word, vs copy-prev-shell-word; those might be cool to look into
delete-word, might be interesting

digit-argument (ESC-0..ESC-9) (1-9), you use escapes to do more than 1 digit, also can use esc--
kill-word, kills current word, `^[D`. wouldnt it be better to delete and not kill? idk. also doesnt go at the front of the word first.
vi-join ^x^j, joins two lines

kill-buffer (^X^K) (unbound) (unbound)
kill-whole-line (^U) (unbound) (unbound) wtf is the difference. maybe an easier way
quote-line ^[' 'Quote the current line
quote-region ^[' 'Quote the current region
self-insert-unmeta (ESC-^I ESC-^J ESC-^M), enter the char while striping the meta bit. might be useful for tabs?

transpose-chars (^T)
transpose-words (ESC-T ESC-t)
    Quote the region from the cursor to the mark.
fi


## TODO: 18.6.5 Completion
# 18.6.6 Miscellaneous

# ----
