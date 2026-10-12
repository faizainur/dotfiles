# dotfiles

Configurations for **Linux (i3wm)** and **macOS**, collated in one repo and
installed into `~/.config` as symlinks — no copying, edit the repo and the
live config changes instantly.

## Layout

Every *direct child directory* of a profile folder is a config, symlinked to
`~/.config/<name>`:

```
.
├── Makefile              # entry points (no config names hardcoded)
├── scripts/link.sh       # discovery + backup + symlink engine
├── shared/               # linked on every OS
│   └── nvim/             # -> ~/.config/nvim
├── i3wm/                 # Linux / i3 profile
│   ├── i3/               # -> ~/.config/i3
│   ├── picom/            # -> ~/.config/picom
│   ├── polybar/          # -> ~/.config/polybar
│   └── rofi/             # -> ~/.config/rofi
└── macosx/               # macOS profile
    └── sketchybar/       # -> ~/.config/sketchybar
```

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

`make uninstall` only removes symlinks that point into this repo — real
directories and backups are never touched. Orphaned links (a config dir since
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

The script discovers it automatically. To keep a folder in the repo but out
of the install (e.g. WIP), prefix it with `_` or `.` — `_scratch/` is skipped.

## Notes

- `i3wm/rofi/rofi-themes-collection` is vendored third-party content; see
  [UPSTREAM.md](i3wm/rofi/rofi-themes-collection/UPSTREAM.md).
- Requirements: `make`, `bash`. macOS ships both (bash 3 is enough — no
  associative arrays or globstar used).
