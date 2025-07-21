# Movement keybinds
The following are the keybinds to move the cursor, and their ZLE plugins

| Esc Seq | Keybind    | ZLE widget             | Description              | Notes |
|-----------------|------------|------------------------|--------------------------|-------|
| `^[[D`          |      ←     | `backward-char`        | Move one character left  | (default) |
| `^[[C`          |      →     | `forward-char`         | Move one character right | (default) |
| `^?`            |      ⌫     | `backward-delete-char` | Delete one char left     | (default) |
| `^[[3~`         |      ⌦     | `delete-char`          | Delete one char right    | (default) |
| `^[b`           |  ⌥ + ←     | `backward-word`        | Move one word left       | (default) |
| `^[f`           |  ⌥ + →     | `forward-word`         | Move one word right      | (default) |
| `^[^?`/`^W`     |  ⌥ + ⌫     | `backward-kill-word`   | Delete one word left     | (Terminal.App keyboard added) |
| `^[D`           |  ⌥ + ⌦     | `kill-word`            | Delete one word right    | (Terminal.App keyboard added) |
| `^[[1;2D`       |  ⬆ + ←     | `SampShell-backward-argument` | Move one shell argument left  | Terminal.app had keybind; ZLE widget made |
| `^[[1;2C`       |  ⬆ + →     | `SampShell-forward-argument`  | Move one shell argument right | Terminal.app had keybind; ZLE widget made |
| `^[[79;2~`      |  ⬆ + ⌫     | `SampShell-backward-kill-argument`  | Delete one shell argument left | Had to create ZLE and Terminal.app keybind; 79 is arbitrary chosen. |
| `^[[3;2~`       |  ⬆ + ⌦     | `SampShell-forward-kill-argument`  | Delete one shell argument right | Had to create ZLE; Terminal.app had keybind.  |

<!-- bindkey '^[[1;2D' SampShell-backward-argument
bindkey '^[[1;2C' SampShell-forward-argument
bindkey '^[[3;2~' SampShell-forward-kill-argument
bindkey '^[[79;2~' SampShell-backward-kill-argument # `79` is arbitrary code i picked that seems unused


| ??              | ?? + ←     | ?? | Move one shell word back | |
| ??              | ?? + ← + X | ?? | Move back to character | |
| `^[^?`          |  ⌥ + ⌫     | `backward-kill-word` | Delete one char left | (terminal keyboard added) |



Notes: `^[` is escape (`\033`), `^?` is del (`\177`).
Also: **⌥** is option, **⬆** is shift.

 →
opt: ⌥
backspace: ⌫
del-right: ⌦
ctrl: ⌃⬆
shift: ⬆️
 -->
