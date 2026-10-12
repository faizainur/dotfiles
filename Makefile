# Dotfiles installer — symlinks every config dir under the profile roots
# into ~/.config (backing up anything already there). No config names are
# hardcoded: scripts/link.sh discovers them from the directory structure, so
# adding a tool is just `mkdir i3wm/alacritty` (or macosx/, shared/).
OS := $(shell uname -s)

.PHONY: install install-linux install-darwin i3wm macos uninstall uninstall-restore status

# Auto-select profile by current OS
install:
ifeq ($(OS),Linux)
	@$(MAKE) --no-print-directory i3wm
else ifeq ($(OS),Darwin)
	@$(MAKE) --no-print-directory macos
else
	@echo "unsupported OS: $(OS) — run 'make i3wm' or 'make macos' explicitly" && exit 1
endif

install-linux: i3wm
install-darwin: macos

# Explicit overrides (shared configs + chosen profile), handy via symlinks
# even when e.g. testing the macOS layout on Linux
i3wm:
	@bash scripts/link.sh link shared i3wm

macos:
	@bash scripts/link.sh link shared macosx

# Remove only symlinks that point into this repo; real dirs and backups stay.
# Add ROLLBACK=1 to also restore the latest ~/.config/<name>.backup* per config.
uninstall:
	@bash scripts/link.sh unlink shared i3wm macosx $(if $(ROLLBACK),--rollback,)

# Same as: make uninstall ROLLBACK=1
uninstall-restore:
	@bash scripts/link.sh unlink shared i3wm macosx --rollback

status:
	@bash scripts/link.sh status shared i3wm macosx
