# AGENTS.md — instructions for AI agents working in this repo

## What this repo is

Dotfiles for **Linux/i3wm** and **macOS**, installed by symlinking from this
repo into the user's home — no copying. The installer is fully **dynamic**:
nothing may hardcode config names anywhere.

## Layout & discovery rules

Direct children of a profile root (`shared/`, `i3wm/`, `macosx/`) are
discovered by `scripts/link.sh` — these rules are the contract:

| Source | Destination | Rule |
|---|---|---|
| `<profile>/<name>/` (dir) | `~/.config/<name>` | each direct child dir; skip `home`, `.`- and `_`-prefixed |
| `<profile>/home/<item>` | `~/<item>` | files **and** dotfiles; `_`-prefix opts out |
| `<profile>/home/shells/<sh>/<item>` | `~/<item>` | only for the selected shell |

- `home` and `shells` are **reserved names** — never use them as config dirs.
- Shell selection: `SH` env/make var; defaults to the detected login shell
  (via `getent`/`dscl`, not `$SHELL`, which make clobbers).
- Adding a tool = `mkdir <profile>/<tool>` (or drop files in `home/`).
  **Never edit Makefile/link.sh to register a name.**

## Makefile targets

`make install` (auto by `uname -s`) · `make i3wm` / `make macos` ·
`make status` · `make uninstall` · `make uninstall-restore` (=
`uninstall ROLLBACK=1`) · `make shells` · all accept `SH=<shell>` overrides.

## Backup semantics (must preserve)

- Existing real file/dir at the destination → `mv` to `<name>.backup`
  (first time), then `<name>.backup.<YYYYMMDDTHHMMSS>` on collision, then
  `.backup.<ts>.<n>` for same-second collisions. **Never delete or overwrite
  user data.** Plain `.backup` is always the oldest; sort order = age.
- `uninstall` removes only symlinks resolving into this repo (raw readlink
  check catches dangling ones too); with `--rollback`, the newest backup is
  `mv`'d back (consumed; older ones kept).
- `status`/`uninstall` must also surface/clean **orphan** links (repo dir
  since deleted).

## Testing changes to the installer

Use a sandbox HOME — never touch the real `~/.config` unless the user
explicitly asks to install:

```sh
H=/tmp/opencode/th; rm -rf $H; mkdir -p $H/.config
HOME=$H SH=zsh bash scripts/link.sh link shared i3wm   # also: status / unlink --rollback
```

Cover at least: fresh link, idempotent re-run, backup of pre-existing real
dirs **and** files, same-second collision, foreign symlink replacement,
orphan cleanup, rollback content check (newest wins). `bash -n
scripts/link.sh` must pass. Keep the script portable to macOS: bash 3.2,
BSD `find`/`ls`, no `realpath`, no GNU-only flags.

## Vendored third-party code

No git submodules. Vendored content lives as plain files (e.g.
`i3wm/rofi/rofi-themes-collection/`) with a **`UPSTREAM.md`** stating origin
repo, license, and vendored commit. Converting an accidental gitlink back to
files requires `git rm --cached -r <path>` before `git add` (plain `git add`
silently skips it).

## nvim config (`shared/nvim/`)

LazyVim-based; read `shared/nvim/README.md` for the full picture. Key rules:

- Customize via `lua/plugins/*.lua` lazy.nvim specs — avoid editing
  `config/options.lua`-style core files unless necessary; prefer overriding
  LazyVim specs (`enabled = false`, `opts = {}` merges).
- Mason `ensure_installed` entries must be **canonical mason package IDs**
  (hyphenated, e.g. `typescript-language-server`), not lspconfig names.
- Formatting: none-ls is deprecated here — conform.nvim (LazyVim default) is
  the formatter; keep `plugins/formatter.lua` as the placeholder documenting
  that history.

### Picker/keymap gotchas (learned building `macros.lua`)

- `feedkeys()` / `nvim_input()` called synchronously inside a picker
  confirm action are **swallowed by the picker's close sequence** — wrap the
  injection in `vim.schedule()`.
- Counts must be captured **when the keymap function runs** (`local count =
  vim.v.count`); by the time an async action (picker confirm) executes,
  `v:count` is long reset. See `macros.lua` `3<leader>m` handling.
- Custom pickers: `finder` accepts a plain function returning item tables
  (`{ text, value, data, preview = { text, ft } }`); `source` is only for
  *registered* source names. Format presets require matching item fields
  (e.g. `format = "register"` needs `.reg`/`.value`).
- Actions resolve `opts.actions` first, then snacks builtins; `confirm`
  accepts a list of action names executed in order.
- Input- and list-window keys are **separate**: a key mapped only in
  `win.list` does not fire while input has focus, and natives are easy to
  collide with (e.g. `<c-v>` = `edit_vsplit` in the input window).
- `<leader>` = space is set by LazyVim itself (`lazyvim/config/options.lua`),
  not by the user's `init.lua`.

### Headless testing recipe (for keymap/picker behavior)

Raw PTY driving and `-c`-time input simulation are **unreliable** — startup
messages raise hit-enter prompts that silently eat every subsequent key.
What worked (validated the macros picker end to end):

```sh
SOCK=/tmp/opencode/sock; rm -f $SOCK
nvim --headless --listen $SOCK somefile.txt 2>/dev/null &   # NOT --listen=...
sleep 4                                                     # let lazy/VeryLazy settle
R() { nvim --server $SOCK "$@"; }                           # NOT --server=...
R --remote-send '<CR>'                                      # clear any hit-enter prompt first!
R --remote-send ':lua vim.fn.setreg("q","x")<CR>'           # set up state
R --remote-send '3 m'; sleep 1.5                            # keycodes ARE parsed
R --remote-send '<CR>'; sleep 2                              # confirm -> play
R --remote-expr 'getline(1)'                                # MUST return a string,
                                                            # not a table/list
```

Run one clean nvim process per case (leftover typeahead between cases
produced false failures). Double-check test *expectations* against real vim
semantics before suspecting the plugin (e.g. `x` deletes forward from the
cursor).

## General

- Commit style: Conventional Commits (`feat:`, `fix:`, `refactor:`, `docs:`,
  `chore:`), split into logical commits; **commit only when asked.**
- The repo is symlinked into the live system: edits under `~/.config/...`
  *are* repo edits — check `git status` before assuming files are untouched.
