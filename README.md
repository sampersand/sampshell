# sampshell
My startup shell files



# SampShell Variables
All variables that are used by sampshell are prefixed with `SampShell_`; exported variables are all-caps (such as `SampShell_ROOTDIR`), and unexported ones are lower-case (such as `SampShell_experimental`)

## Exported
| Variable name | Default | Description |
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

## Misc
`$words` is set if it's not already set.
