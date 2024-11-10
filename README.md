# sampshell
My shell startup files.

This repo contains all the standard definitions and configuration I use for my shells; It's 100% usable from any POSIX-compliant shell!

# Quick Start
Add the following to the shell's startup files (`~/.zshrc`, `~/.bash_profile`, etc.):
```sh
### Load SampShell after other third-party stuff
# SampShell relies on other things being executed first, as it loads config based on the presence of
# some commands (eg `git`), and also sets up some aliases (eg `alias mv='mv -i'`) which might not
# play well with other config scripts.
export PATH="$PATH:/some/path/here"
. "$HOME/.my-company/company-specific-config-files.sh"
# ... whatever else


### Setup `SampShell_xxx` config variables
# These should be done before `.`ing SampShell, as some config files expect these to be defined, or
# will use default values. Note that SampShell will `export` variables itself, so you dont need to.
SampShell_TMPDIR=$HOME/tmp
SampShell_git_branch_prefix=swesterman

### Set `SampShell_ROOTDIR` (if needed)
# This is the path to the root of SampShell, and must be present so SampShell knows where other
# files are. Some shells (eg ZSH and Bash) are able to automatically determine it, and so this can
# be omitted in those shells. If it's omitted, it's assumed to be `$HOME/.sampshell`, and a warning
# is emitted.
SampShell_ROOTDIR=$HOME/me/sampshell

### Load SampShell itself
. "$SampShell_ROOTDIR/both.sh"

### Do any setup that requires SampShell loaded
# (Note these are ZSH-specific setup)
add-named-dir ~/me
add-named-dir ~/code
make-prompt --show-login-info=1
```

# The Distinction between `env` and `interactive`
SampShell actually has two separate set of config files: those for interactive-and-non-interactive shells (the `env.EXT` files), and those exclusively interactive shells (the `interactive.EXT` files). The top-level `env.sh` and `interactive.sh` files are designed so that `.`ing them will load all relevant env/interactive config; there's no need to `.` _any_ files below the top-level.

The `env` files are intended to be `.`able from within scripts, to provide access to SampShell functionality (eg the `$PATH`, functions such as `SampShell_log`, etc.). Thus, they make few assumptions about their enclosing environment, and only _add_ things. As such, no `alias`es are defined, and all variables and functions in `env` files start with `SampShell_` (ZSH uses `SampShell-` for functions). 

Conversely, the `interactive` files are intended to be `.`ed for interactive use, usually within a shell's startup files. Therefore, they make more assumptions about their enclosing environment (importantly, that the `env` files files have been `.`d, but also things like `set -o pipefail` aren't enabled). Additionally, they do more "destructive" changes, such as adding `alias`es, and (usually) not prefix functions/variables with `SampShell_`.

## The `both.sh` file
Because the `interactive` startup files are a bit more "destructive," it's preferable to not include them within scripts. This is where `both.sh` comes into play: When you `.` it, it will always `.` the `env.sh` file, and then will only `.` the `interactive.sh` file if we're in an interactive shell.

This is incredibly useful, especially for shells which don't have separate startup files for interactive vs non-interactive instances, or when you're lazy and dont want to figure out what to put where. However, `both.sh` is a bit of a kludge; in shells with both interactive and non-interactive startup files, you probably want to split it up so that you `. /path/to/sampshell/env.sh` in non-interactive shells and `. /path/to/sampshell/interactive.sh` in interactive shells. (This is in case third-party scripts are `.`d after the interactive shell loads, as they probably won't be too happy with some of the changes that SampShell makes to the interactive environment.)

# SampShell Variables
All config variables that're used within SampShell are prefixed with `SampShell_`; exported variables are all-caps (eg `SampShell_ROOTDIR`), and unexported ones are lower-case (eg `SampShell_git_default_master_branch`).


| Variable Name | Default | Description |
| ------------- | ------- | ----------- |
| `SampShell_ROOTDIR` | The `dirname` of `$0` passed to `{non-,}interactive.sh` | The root directory where SampShell is located |
| `SampShell_EDITOR` | `sublime4` | The editor used for `subl` and associated commands |
| `SampShell_TRASHDIR` | `$HOME/.Trash/.sampshell-trash` | The destination for the `trash` command |
| `SampShell_TMPDIR` | `$HOME/tmp` | A temporary directory; different from `/tmp` as this persists between restarts, if needed. |
| `SampShell_WORDS` | `/usr/share/dict/words` | Unused by SampShell, but I use it frequently. |
| `SampShell_HISTDIR` | `$SampShell_ROOTDIR/.sampshell-history` | The folder where history commands go |


REPORTTIME - 5 second default

## Unexported
| Variable name | Default | Description |
| ------------- | ------- | ----------- |
| `SampShell_noninteractive_loaded` | N/A | Set when `non-interactive.sh` is run; used by `interactive.sh` to not source `non-interactive.sh` twice. |
| `SampShell_experimental` | (unset) | If set, enables "experimental" features I'm trying out |
| `SampShell_git_default_master_branch` | `master` | The default master branch for git if master can't be determined. |
| `SampShell_git_branch_prefix` | `$(whoami)` | The username prefix on git branches. |
| `SampShell_git_branch_prefix_pattern` | `$SampShell_git_branch_prefix/??-??-??` | The pattern for branch prefixes; used in PS1 in zsh. |
| `SampShell_paralleize_it_skip_string` | `x` | The string to skip previous commands in `parallelize-it` |
| `SampShell_dont_set_PS1` | (unset) | if set and nonempty, ps1 is not set |

# Shell-specific config
zsh does reporttime
