alias obviated-by-another-binding='bindkey -r'
alias will-never-use='bindkey -r'
alias already-using=':'
alias should-start-using=':'
alias may-start-using=':'
alias what-is-this=':'
alias macos-has-it-so-keep-it=':'
alias special-builtin=':'

"^[[3~" delete-char

## 18.6.1 Movement
obviated-by-another-binding '^B' # arrow keys overwrite
obviated-by-another-binding '^F' # arrow keys overwrite
already-using '^[B' # backward-word <-- already bultin via ctrl + left arrow
already-using '^A ' # beginning-of-line, already use this
already-using '^E ' # end-of-line, already use this
already-using '^[F' # forward-word, emitted by terminal already

will-never-use '^X^F' # vi-find-next-char, enter a char and go to that
will-never-use '^[|'  # vi-goto-column, goes to a specific column on the cmd line

## 18.6.2 History Control
will-never-use '^[<' # beginning-of-buffer-or-history, goes to the start of history it looks like
will-never-use '^[>' # end-of-buffer-or-history, goes to end of history.
obviated-by-another-binding '^N' # arrow keys overwrite, down-line-or-history
obviated-by-another-binding '^P' # arrow keys overwrite, up-line-or-history

already-using '^R' # history-incremental-search-backward, history search
will-never-use '^S' # history-incremental-search-forward, opposite of `^R`
should-start-using '^Xr' # if i replace `^R`, maybe?
should-start-using '^Xr' # if i replace `^r` and `^s`, figure this out

will-never-use '^[P' '^[p' # history-search-backward, like incremental search, but just uses first word; i can just `!?x` instead
will-never-use '^[N' '^[n' # history-search-forward, even less useful

will-never-use '^X^N' # infer-next-history, look for a line exactly matching this, and get the line after it. i coudl see it beinguseful in a niche maybe
will-never-use '^[_' # insert-last-word, just use `^[.`
should-start-using '^[.' # insert-last-word, like `!$`

## 18.6.3 Modifying Text
obviated-by-another-binding '^H' # backward-delete-char, delete does this
should-start-using '^[^?'  # backward-kill-word , delete a word backwards. TODO: posix one
will-never-use '^W' # backward-kill-word, i may use `^W`
will-never-use '^[^H' # backward-kill-word, just use the escape + delete key . or maybe rebidn to ctrl + delete
may-start-using '^D' '^d' # I may start using this

will-never-use '^[C' '^[c' # capitalize-word, i have no need for this
will-never-use '^[L' '^[l' # lowercase-word, i have no need for this
will-never-use '^[U' '^[u' # uppercase-word, i have no need for this

will-never-use '^[W' '^[w' # copy-region-as-kill, I don't plan on learning the kill buffer really.
will-never-use '^[^_' # copy-prev-word, copies the word behind the cursor. Like, just highlight it lol.
will-never-use '^X^J' # vi-join, Im not really going to do multiline editing in ZSH
macos-has-it-so-keep-it '^K' # kill-line, I dont use it a ton, but it's in macos, so im going to keep it around lol

what-is-this '^X^K' # kill-buffer, whatsthe diff between this and kill-whole-line?
should-start-using '^U' # kill-whole-line, clear the line. but it's like ctrl+c, so eh?
should-start-using '^X^B' # vi-match-bracket, might be pretty interesting
will-never-use '^X^O' # overwrite-mode, I have no need to use overwrite mode, i hate it when it's turned on accidentally

may-start-using '^V' # quoted-insert, next char is inserted literally
may-start-using "[^'" # quote-line, quote the entire line
will-never-use '^["' # quote the region; i dont see myself using regions often, and when i do, i dont need to quote them lol

should-start-using '^[^I' '^[^J' '^[^M' # self-insert-unmeta, insert a literal tab/newline instead of their normals
macos-has-it-so-keep-it '^T' # transpose-chars, i dont use butmacos has it so keep i taorund
may-start-using '^[T' # transpose-words, i doubt i'll learn how to use this but i may

## 18.6.4 Arguments
may-start-using '^[0'..'^[9' # digit-argument, used for args to keybinds, if need be.
may-start-using '^[-'        # negates the argument
will-never-use '^D' # delete-char-or-list, just use delete or tab lol
already-using '^I' # expand-or-complete, already using tab to expand andcomplete

will-never-use '^[ ' '^[!' # expand-history, just hit tab normally.
will-never-use '^X*' # expand-word, just use tab lol
will-never-use '^[^D' # list-choices, just hit tab lol, then undo if you dont like it
may-start-using '^Xg' '^XG' # list-expand, expands it out, but doesnt actually insert it. works weirdly with history

todo, whats the diff between accept-line-and-down-history and accept-and-hold
should-start-using '^[A' '^[a' # accept-and-hold, run the command but dont get rid of it
    ^ TODO: maybe make this ctrl+enter?
already-using '^J' '^M' #accept-line, this is just enter

should-start-using '^[[200~' # bracketed-paste; woah i could braket urls and whatnot
will-never-use '^X^V' # vi-cmd-mode, i dontuse vi commands lol
will-never-use '^L' '^[L' # clear-screen, terminal just has cmd+k
will-never-use '^X^X' # exchange-point-and-mark, i dont intend to use marks that much.
may-start-using '^[x' # execute-named-cmd, special case, execute a command directly without binding itt o a key
will-never-use '^[z' # execute-last-named-cmd, does the last execute-named-command for you. kinda silly

may-start-using '^[G' '^[g' #get-line, todo what is the buffer stack
^ TODO what is the buffer stack

should-start-using '^Q' '^[Q' '^[q' # push-line, pushes a line into the buffer of commands, and will read it after your current command

echo hi


