# dotfiles

Configurations for **Linux (i3wm)** and **macOS**, collated in one repo and
installed into `~/.config` as symlinks — no copying, edit the repo and the
live config changes instantly.

## Layout

Everything is discovered from the directory structure — no names hardcoded
anywhere. Each profile folder (`shared/`, `i3wm/`, `macosx/`) follows two
rules:

- a direct **child directory** → symlinked to `~/.config/<name>`
- a **`home/`** dir → each of its items (files *and* dotfiles) → `~/<item>`
- **`home/shells/<shell>/`** → items of the *chosen* shell only → `~/<item>`

```
.
├── Makefile              # entry points (no config names hardcoded)
├── scripts/link.sh       # discovery + backup + symlink engine
├── shared/               # linked on every OS
│   ├── alacritty/        # -> ~/.config/alacritty
│   ├── nvim/             # -> ~/.config/nvim
│   └── home/
│       └── shells/
│           └── zsh/
│               └── .zshrc        # -> ~/.zshrc  (when shell=zsh)
├── i3wm/                 # Linux / i3 profile
│   ├── home/             # (optional) i3-specific files for ~
│   ├── i3/  picom/  polybar/  rofi/   # -> ~/.config/<name>
└── macosx/               # macOS profile
    ├── home/
    │   └── .aerospace.toml     # -> ~/.aerospace.toml
    └── sketchybar/       # -> ~/.config/sketchybar
```

`home` and `shells` are reserved names; children prefixed `_` or `.` are
skipped as configs, so `_scratch/` stays in the repo but out of the install.

## Shell selection

The shell under `home/shells/` defaults to your **detected login shell**
(via `getent`/`dscl`, so it works even under make's `/bin/sh`). Override per
command:

```sh
make install SH=zsh     # or bash, fish, ...
make shells             # list available shell dirs
```

When changing shells, run `make uninstall` first — switching `SH` does not
unremove links created for the previous shell.

## Usage

```sh
make install      # auto-detect OS (uname): Linux -> i3wm, macOS -> macosx
make i3wm         # explicit: shared + i3wm configs
make macos        # explicit: shared + macOS configs
make status       # see what's linked / would change, without touching anything
make uninstall              # remove symlinks that point into this repo
make uninstall ROLLBACK=1   # ...and restore the latest backup per config
make uninstall-restore      # alias for the above
```

### Uninstall & rollback

`make uninstall` only removes symlinks that point into this repo — from both
`~/.config` and `$HOME` — and real directories/files and backups are never
touched. Orphaned links (a config dir since
deleted from the repo) are cleaned up too. With `ROLLBACK=1`
(or `make uninstall-restore`), after removing each link the newest backup
for that config (`<name>.backup`, `<name>.backup.<timestamp>`, or
`<name>.backup.<timestamp>.<n>`) is moved back to `~/.config/<name>`.
Older timestamped backups are kept.

### Backups

If `~/.config/<name>` already exists as a real directory or file, it is moved
to `~/.config/<name>.backup` before linking (nothing is ever deleted):

- `<name>.backup` taken → `<name>.backup.<YYYYMMDDTHHMMSS>`
- a previous run's symlink → replaced silently
- `make uninstall` only removes symlinks into this repo, never backups

## Adding a config

Create a directory under the right profile and run `make install`:

```sh
mkdir -p i3wm/alacritty && touch i3wm/alacritty/alacritty.toml
make install
```

For files that belong in `$HOME` itself (`.zshrc`, `.profile`, …), drop them
under `<profile>/home/`, or under `<profile>/home/shells/<shell>/` if they
are shell-specific. The script discovers all of it automatically. To keep a
folder in the repo but out of the install (e.g. WIP), prefix it with `_` or
`.` — `_scratch/` is skipped.

## Notes

- `i3wm/rofi/rofi-themes-collection` is vendored third-party content; see
  [UPSTREAM.md](i3wm/rofi/rofi-themes-collection/UPSTREAM.md).
- Requirements: `make`, `bash`. macOS ships both (bash 3 is enough — no
  associative arrays or globstar used).
