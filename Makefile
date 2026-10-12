# Dotfiles installer — dynamically symlinks configs into ~/.config and
# home dotfiles into $HOME (see scripts/link.sh + README). No config names
# hardcoded: adding a tool is just `mkdir i3wm/alacritty`.
OS := $(shell uname -s)

# Which shell's files under <profile>/home/shells/ link into $HOME.
# Default: auto-detected login shell. Override, e.g.:  make install SH=zsh
SH ?=

LINK = SH="$(SH)" bash scripts/link.sh

.PHONY: install install-linux install-darwin i3wm macos uninstall uninstall-restore status shells

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

# Explicit overrides (shared configs + chosen profile)
i3wm:
	@$(LINK) link shared i3wm

macos:
	@$(LINK) link shared macosx

# Remove only symlinks that point into this repo (both ~/.config and $HOME);
# real files/dirs and backups are never touched. Add ROLLBACK=1 to also
# restore the newest backup for each removed entry.
uninstall:
	@$(LINK) unlink shared $(if $(ROLLBACK),--rollback,)

# Same as: make uninstall ROLLBACK=1
uninstall-restore:
	@$(LINK) unlink shared --rollback

status:
	@$(LINK) status shared i3wm macosx

# List available shell configs under <profile>/home/shells/
shells:
	@$(LINK) shells shared i3wm macosx
