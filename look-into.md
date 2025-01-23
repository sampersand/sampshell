zsh autoloads
------
promptnl
  # generate pattern to match all known math functions
  mathfuncs=(abs acos acosh asin asinh atan atanh cbrt ceil cos cosh erf erfc
    exp expm1 fabs float floor gamma int j0 j1 lgamma log log10 log1p logb
    sin sinh sqrt tan tanh y0 y1 signgam copysign fmod hypot nextafter jn yn
    ldexp scalb rand48)


---others

- `SHELL_SESSIONS_DISABLE` in macos

disable -p, to disable patterns!
--
`\ex + where-is`

echo hi there frined what is up with you today
4.3.3: Prefix (digit) arguments

^ means ctrl, ^[ means escape
`^W` deletes a word to the left
`^[xu` undoes
up arrow a bunch, then `^o` executes that, then asks if you want to execute the nextline
# TODO: history, and see if you can just press a key to get the omst recent one
hitting `^r` multiple times lets you go back further, woah

---


$_
$ZSH_ARGZERO
DIRSTACKSIZE <-- no need to, why limit it?
CORRECT
NO_PUSHD_TO_HOME <-- dont need it so i wont remember either way
CASE_GLOB
NUMERIC_GLOB_SORT
`$ <foo` reads foo in 

- If the shell encounters the character sequence ‘!"’ in the input, the history mechanism is temporarily disabled until the current list (see Shell Grammar) is fully parsed. The ‘!"’ is removed from the input, and any subsequent ‘!’ characters have no special significance. 

---
√ 16.2.1 Changing Directories
16.2.2 Completion
√ 16.2.3 Expansion and Globbing
16.2.4 History
√ 16.2.5 Initialisation
√ 16.2.6 Input/Output
√ 16.2.7 Job Control
16.2.8 Prompting
√ 16.2.9 Scripts and Functions
√ 16.2.10 Shell Emulation
16.2.11 Shell State
16.2.12 Zle

https://zsh.sourceforge.io/Doc/Release/Parameters.html
\## COMMANDS TO LOOK INTO:
- `du`, `df`, `file`, `mkfile`, `crontab`, `at`, `batch`
- `comm`, `cut`, `fold`, `join`, `paste`, `patch`

autoload -U bracketed-paste-url-magic; zle -N bracketed-paste bracketed-paste-url-magic

# Notes
the `.zsh{env,rc}` files are where config are setup; the `interactive/*` is just where comands/aliases are registered.

# Fun things

- pattern matching! `(#s)` and `(#e)` are beginning and end of line
Some fun thigns:
- you can overload `~[foo]` via the `zsh_directory_name` function
- `cat =(<<<foo)` --- TODO: what does NULLCMD do?
- `$ <file` just passes it to `more` (Technically READNULLCMD)

- `print -zr – $ZLE_LINE_ABORTED` is the previous line
- you can `disown` jobs to not have the shell interact with them anymore. also `&|` at teh end does it.

how does fignore work?
--
HISTORY_IGNORE

    If set, is treated as a pattern at the time history files are written. Any potential history entry that matches the pattern is skipped. For example, if the value is ‘fc *’ then commands that invoke the interactive history editor are never written to the history file.

    Note that HISTORY_IGNORE defines a single pattern: to specify alternatives use the ‘(first|second|...)’ syntax.

    Compare the HIST_NO_STORE option or the zshaddhistory hook, either of which would prevent such commands from being added to the interactive history at all. If you wish to use HISTORY_IGNORE to stop history being added in the first place, you can define the following hook:

    zshaddhistory() {
      emulate -L zsh
      ## uncomment if HISTORY_IGNORE
      ## should use EXTENDED_GLOB syntax
      # setopt extendedglob
      [[ $1 != ${~HISTORY_IGNORE} ]]
    }

 LISTMAX

    In the line editor, the number of matches to list without asking first. If the value is negative, the list will be shown if it spans at most as many lines as given by the absolute value. If set to zero, the shell asks only if the top of the listing would scroll off the screen. 



PROMPT_EOL_MARK

    When the PROMPT_CR and PROMPT_SP options are set, the PROMPT_EOL_MARK parameter can be used to customize how the end of partial lines are shown. This parameter undergoes prompt expansion, with the PROMPT_PERCENT option set. If not set, the default behavior is equivalent to the value ‘%B%S%#%s%b’. 


TIMEFMT

    The format of process time reports with the time keyword. The default is ‘%J %U user %S system %P cpu %*E total’. Recognizes the following escape sequences, although not all may be available on all systems, and some that are available may not be useful:

    %%

        A ‘%’. 
    %U

        CPU seconds spent in user mode. 
    %S

        CPU seconds spent in kernel mode. 
    %E

        Elapsed time in seconds. 
    %P

        The CPU percentage, computed as 100*(%U+%S)/%E. 
    %W

        Number of times the process was swapped. 
    %X

        The average amount in (shared) text space used in kilobytes. 
    %D

        The average amount in (unshared) data/stack space used in kilobytes. 
    %K

        The total space used (%X+%D) in kilobytes. 
    %M

        The maximum memory the process had in use at any time in kilobytes. 
    %F

        The number of major page faults (page needed to be brought from disk). 
    %R

        The number of minor page faults. 
    %I

        The number of input operations. 
    %O

        The number of output operations. 
    %r

        The number of socket messages received. 
    %s

        The number of socket messages sent. 
    %k

        The number of signals received. 
    %w

        Number of voluntary context switches (waits). 
    %c

        Number of involuntary context switches. 
    %J

        The name of this job. 

	A star may be inserted between the percent sign and flags printing time (e.g., ‘%*E’); this causes the time to be printed in ‘hh:mm:ss.ttt’ format (hours and minutes are only printed if they are not zero). Alternatively, ‘m’ or ‘u’ may be used (e.g., ‘%mE’) to produce time output in milliseconds or microseconds, respectively. 

TMPPREFIX

    A pathname prefix which the shell will use for all temporary files. Note that this should include an initial part for the file name as well as any directory names. The default is ‘/tmp/zsh’. 

WORDCHARS <S>

    A list of non-alphanumeric characters considered part of a word by the line editor. 


$pipestatus <S> <Z>

    An array containing the exit statuses returned by all commands in the last pipeline. 

$_ <S>

    The last argument of the previous command. Also, this parameter is set in the environment of every command executed to the full pathname of the command. 


14.8.5 Approximate Matching

When matching approximately, the shell keeps a count of the errors found, which cannot exceed the number specified in the (#anum) flags. Four types of error are recognised:

1.

    Different characters, as in fooxbar and fooybar.
2.

    Transposition of characters, as in banana and abnana.
3.

    A character missing in the target string, as with the pattern road and target string rod.
4.

    An extra character appearing in the target string, as with stove and strove.

Thus, the pattern (#a3)abcd matches dcba, with the errors occurring by using the first rule twice and the second once, grouping the string as [d][cb][a] and [a][bc][d].

Non-literal parts of the pattern must match exactly, including characters in character ranges: hence (#a1)??? matches strings of length four, by applying rule 4 to an empty part of the pattern, but not strings of length two, since all the ? must match. Other characters which must match exactly are initial dots in filenames (unless the GLOB_DOTS option is set), and all slashes in filenames, so that a/bc is two errors from ab/c (the slash cannot be transposed with another character). Similarly, errors are counted separately for non-contiguous strings in the pattern, so that (ab|cd)ef is two errors from aebf.

When using exclusion via the ~ operator, approximate matching is treated entirely separately for the excluded part and must be activated separately. Thus, (#a1)README~READ_ME matches READ.ME but not READ_ME, as the trailing READ_ME is matched without approximation. However, (#a1)README~(#a1)READ_ME does not match any pattern of the form READ?ME as all such forms are now excluded.

Apart from exclusions, there is only one overall error count; however, the maximum errors allowed may be altered locally, and this can be delimited by grouping. For example, (#a1)cat((#a0)dog)fox allows one error in total, which may not occur in the dog section, and the pattern (#a1)cat(#a0)dog(#a1)fox is equivalent. Note that the point at which an error is first found is the crucial one for establishing whether to use approximation; for example, (#a1)abc(#a0)xyz will not match abcdxyz, because the error occurs at the ‘x’, where approximation is turned off.

Entire path segments may be matched approximately, so that ‘(#a1)/foo/d/is/available/at/the/bar’ allows one error in any path segment. This is much less efficient than without the (#a1), however, since every directory in the path must be scanned for a possible approximate match. It is best to place the (#a1) after any path segments which are known to be correct. 



https://zsh.sourceforge.io/Doc/Release/Shell-Builtin-Commands.html:
-h

    Hide: only useful for special parameters (those marked ‘<S>’ in the table in Parameters Set By The Shell), and for local parameters with the same name as a special parameter, though harmless for others. A special parameter with this attribute will not retain its special effect when made local. Thus after ‘typeset -h PATH’, a function containing ‘typeset PATH’ will create an ordinary local parameter without the usual behaviour of PATH. Alternatively, the local parameter may itself be given this attribute; hence inside a function ‘typeset -h PATH’ creates an ordinary local parameter and the special PATH parameter is not altered in any way. It is also possible to create a local parameter using ‘typeset +h special’, where the local copy of special will retain its special properties regardless of having the -h attribute. Global special parameters loaded from shell modules (currently those in zsh/mapfile and zsh/parameter) are automatically given the -h attribute to avoid name clashes.
-H

    Hide value: specifies that typeset will not display the value of the parameter when listing parameters; the display for such parameters is always as if the ‘+’ flag had been given. Use of the parameter is in other respects normal, and the option does not apply if the parameter is specified by name, or by pattern with the -m option. This is on by default for the parameters in the zsh/parameter and zsh/mapfile modules. Note, however, that unlike the -h flag this is also useful for non-special parameters.
---
# TODO optoins to look into

ESC[?47l    restore screen
ESC[?47h    save screen

## 16.2.3 Expansion and Globbing
setopt HIST_SUBST_PATTERN # TODO
setopt HIST_LEX_WORDS # Look into that
setopt MARK_DIRS
setopt APPEND_HISTORY
setopt PATH_DIRS
setopt FUNCTION_ARGZERO # DEFAULT; when to set this?
setopt LOCAL_PATTERNS # <-- look into

CORRECT_IGNORE=
CORRECT_IGNORE_FILE=
LISTMAX=30 # the default, i think; ask when listing more than this
TIMEFMT=$TIMEFMT # look into this
return

### These were borrowed from someone, and i want to look into using them myself
SampShell_exec-or-edit () if [[ -x $1 ]]; then
    $1
else
    subl $1
fi

alias -s {sh,zsh,py}=SampShell_exec-or-edit
alias -s {txt,json,ini,toml,yml,yaml,xml,html,md,lock,snap,rst,cpp,h,rs}=subl
alias -s {log,csv}=bat
alias -s git='git clone'
alias -s o='nm --demangle'
alias -s so='ldd'
###

location=$(readlink -f ${(%):-%N}) what lol


---
I'm trying to do `~/.config/bindkeys/clear-screen` , with `fpath[1,0]=(~/.config/bindkeys)` , and I'm hoping that `^L` uses my custom clear screen, but it doesn't seem like it wants to work. I even tried `autoload -Uz clear-screen`

I notice the description for `HIST_FCNTL_LOCK` mentions ". On recent operating systems this may provide better performance, in particular avoiding history corruption when files are stored on NFS." ; is there any reason _not_ to set this on any modern computer?

Unrelated, I was talking with a friend of mine who has some ZSH setup scripts too. They put at the top of theirs `location=$(readlink -f ${(%):-%N})` , as opposed to my `location=${0:P:h}`. Is there any reason to use theirs over mine?


https://zsh.sourceforge.io/Guide/zshguide04.html#zle
 Suppose you've already gone through a few continuation lines in the normal way with $PS2's? You can't scroll back then, even though the block hasn't yet been edited. There's a magic way of turning all those continuation lines into a single block: the editor command push-line-or-edit. If you're not on a continuation line, it acts like the normal push-line command, which we'll meet below, but for present purpose you use it when you are on a continuation line. You are presented with a seamless block of text from the (redrawn) prompt to the end which you can edit as one. It's quite reasonable to bind push-line-or-edit instead of push-line, to either ^q or \eq (in Emacs mode, which I will assume, as usual). Be careful with ^q, though --- if the option flowcontrol is set it will probably be swallowed up by the terminal driver and not get through to the shell, the same problem I mentioned above for ^s.

 -U string

    This pushes the characters in the string onto the input stack of ZLE. After the widget currently executed finishes ZLE will behave as if the characters in the string were typed by the user.

    As ZLE uses a stack, if this option is used repeatedly the last string pushed onto the stack will be processed first. However, the characters in each string will be processed in the order in which they appear in the string.

-F [ -L | -w ] [ fd [ handler ] ] whatnow?

set-local-history

    By default, history movement commands visit the imported lines as well as the local lines. This widget lets you toggle this on and off, or set it with the numeric argument. Zero for both local and imported lines and nonzero for only local lines.

^^ what's an imported line

Hi all! I'm learning how to use `bindkey` in ZSH, and i'm coming across a problem: How on earth do you bind the option key, or the shift key? from what I can tell, `^` stands for "control" (eg `^x` is ctlr+x) and `^[` means escape (`^[x` is escape + x). I'm pretty sure you cant bind the command key at all, but if you could, being able to bind cmd+z would be amazing lol
im posting hereon the off chance thatsomeone knows
