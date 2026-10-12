# Upstream

This directory is **not** written by us. It is vendored from the original
work of [lr-tech](https://github.com/lr-tech):

- Repository: <https://github.com/lr-tech/rofi-themes-collection>
- License: see [LICENSE](LICENSE) in this directory
- Vendored at commit `911cc27afe9c66d7e2cb06a47c905d046ea3dfd2` (2026-07-18)

It is kept as plain files (deliberately **not** a git submodule) so that a
fresh clone of this repo immediately contains the themes that `rofi/config`
references. The whole `rofi/` folder — themes included — is symlinked to
`~/.config/rofi`.

## Updating

Re-clone upstream into a temporary directory and copy the contents over,
preserving this file:

```sh
git clone https://github.com/lr-tech/rofi-themes-collection /tmp/rtc
rsync -a --exclude UPSTREAM.md /tmp/rtc/ i3wm/rofi/rofi-themes-collection/
rm -rf /tmp/rtc
```
