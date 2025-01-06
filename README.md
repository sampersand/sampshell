# sampshell
My shell startup files.

This repo contains all the standard definitions and configuration I use for my shells; It's 100% usable from any POSIX-compliant shell!


# Quick Start
Add the following to the shell's startup files (`~/.zshrc`, `~/.bash_profile`, etc.):
```sh
## Do non-SampShell setup
# SampShell relies on other things being executed first, as it loads config
# based on the presence of some commands (eg `git`), and also sets up aliases
# (eg `alias mv='mv -i'`) which might not play well with other scripts.
export PATH="$PATH:/some/path/here"
. "$HOME/.my-company/company-specific-config-files.sh"
etc...

## Setup `SampShell_xxx` config variables
# These should be done before `.`ing SampShell, as some functions expect these
# to be defined, or will use default values. Note that SampShell will `export`
# variables itself, so you dont need to.
SampShell_TMPDIR=$HOME/tmp
SampShell_git_branch_prefix=swesterman

## Set `SampShell_ROOTDIR` (if needed)
# This is the path to the root of SampShell, and must be present so SampShell
# knows where other files are. Some shells (eg ZSH and Bash) are able to
# automatically determine it, and so this can be omitted in those shells. If it
# is omitted, it's assumed to be `$HOME/.sampshell`, and a warning is emitted.
SampShell_ROOTDIR=$HOME/me/sampshell

## Load SampShell itself
. "$SampShell_ROOTDIR/both.sh"

## Do any setup that requires SampShell loaded
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

## POSIX Variables, `env`
| Variable Name        | Default                                | Description                                                                        |
|:---------------------|----------------------------------------|:-----------------------------------------------------------------------------------|
| `SampShell_ROOTDIR`  | (see `env.sh`)                         | The root directory of where SampShell is located.                                  |
| `SampShell_gendir`   | `$HOME` (or if unset, `/tmp`)          | The directory where "sampshell" files/folders are created.                         |
| `SampShell_TRASHDIR` | `$SampShell_gendir/.sampshell-trash`   | The default directory for the `trash` command.                                     |
| `SampShell_TMPDIR`   | `$SampShell_gendir/tmp`                | The directory for temp files for SampShell, and the `cdtmp` cmd. (note we don't actually use it for anything other than `cdtmp` and `~tmp` currently...)                   |
| `SampShell_HISTDIR`  | `$SampShell_gendir/.sampshell-history` | If `HISTFILE` is not already setup, the default folder for it. (Also used in ZSH.) |
| `SampShell_EDITOR`   | `sublime4`                             | The default editor for `subl`.                                                     |
| `SampShell_VERBOSE`  | `1` if interactive, (empty) otherwise  | Whether to log verbose messages (used in `SampShell_log`).                         |
| `SampShell_TRACE`    | (empty)                                | If set to `1`, all SampShell scripts will `set -o xtrace` at the very start.       |
| `SampShell_scratch`  | N/A                                    | Used within POSIX-compliant shell functions; always unset upon exit.               |

## POSIX Variables, `interactive`
| Variable Name | Default | Description |
|:--------------|---------|-------------|
| `SampShell_no_experimental` | (unset) | If set to a nonempty value, enables "experimental features" I'm not quite sure about yet. |
| `SampShell_git_default_master_branch` | `master` | Used in git commands when a master branch can't be automatically determined. |
| `SampShell_git_branch_prefix` | `swesterman` | The username to use in git branches (which are in the format `<prefix>/YY-MM-DD/branch-name`) |
| `SampShell_WORDS` | `/usr/share/dict/words` | A word list; not actually used within SampShell, but I find it useful. |
| `words` | `$SampShell_WORDS` | Only set if `$words` doesn't exist; not used within SampShell, but I find it useful. |

## ZSH Variables
| Variable Name | Default | Description |
|---------------|---------|-------------|
| `SampShell_nosave_hist` | (unset) | Used internally within the `{disable,enable}-history` functions. |
| `SampShell_HISTDIR`  | (see "POSIX Variables") | If set, history commands are also stored here (in addition to the main shell history)|
