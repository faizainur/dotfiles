#!/usr/bin/env bash
# link.sh — dynamically symlink every config in this repo into ~/.config (dirs)
#           and $HOME (dotfiles under <profile>/home/ and the chosen shell).
#
# Usage: scripts/link.sh <mode> <profile-dir> [...] [--rollback]
#   mode        link | unlink | status | shells
#   profile-dir directories whose *direct* children are configs to manage
#   --rollback  (unlink) restore the newest ~/.config|~ <name>.backup*
#
# Layout conventions (all dynamic — add files/dirs, never edit this script):
#   <profile>/<name>/        -> ~/.config/<name>        (each child dir)
#   <profile>/home/<item>    -> $HOME/<item>            (files AND dotfiles)
#   <profile>/home/shells/<sh>/<item> -> $HOME/<item>   (only for the chosen SH)
#
# Selection of the shell comes from $SH, defaulting to the detected login
# shell (zsh/bash/fish/...). 'home' and 'shells' are reserved names. Children
# starting with '.' or '_' are skipped as configs; inside home, only '_' is a
# skip so dotfiles like .zshrc are linked.
set -euo pipefail

usage() {
    echo "usage: $(basename "$0") <link|unlink|status|shells> <profile-dir> [...] [--rollback]" >&2
    exit 2
}

MODE="${1:-}"
case "$MODE" in link | unlink | status | shells) ;; *) usage ;; esac
shift
[ $# -ge 1 ] || usage

ROLLBACK=0
ROOTS=()
for arg in "$@"; do
    case "$arg" in
        --rollback) ROLLBACK=1 ;;
        *) ROOTS+=("$arg") ;;
    esac
done
[ ${#ROOTS[@]} -ge 1 ] || usage

CONFIG_HOME="${HOME}/.config"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Detect the user's login shell even when $SHELL has been clobbered (make
# forces SHELL=/bin/sh for recipes). Prefers getent (Linux) then dscl (macOS).
detect_shell() {
    local user="${USER:-$(id -un)}" s=""
    if command -v getent >/dev/null 2>&1; then
        s="$(getent passwd "$user" 2>/dev/null | cut -d: -f7 || true)"
    fi
    [ -z "$s" ] && command -v dscl >/dev/null 2>&1 && \
        s="$(dscl . -read "/Users/$user" UserShell 2>/dev/null | awk '{print $NF}')"
    [ -z "$s" ] && s="${SHELL:-}"
    printf '%s\n' "${s##*/}"
}
SH="${SH:-}"; [ -z "$SH" ] && SH="$(detect_shell)"

# Where ~/.config/<name> or ~/<name> currently points, resolved to an
# absolute path. Returns empty for real dirs/files and broken/relative
# symlinks we cannot resolve portably (no readlink -f / realpath on macOS).
link_target() {
    local dest raw
    dest="$(readlink "$1" 2>/dev/null)" || return 0
    case "$dest" in
        /*) printf '%s\n' "${dest%/}" ;;
        *)
            raw="$(cd "$(dirname "$1")" 2>/dev/null && cd "$dest" 2>/dev/null && pwd)" || return 0
            printf '%s\n' "$raw"
            ;;
    esac
}

# True if target is a symlink into this repo (raw OR resolved) — raw check
# catches dangling links (repo dir since deleted).
is_repo_link() {
    [ -L "$1" ] || return 1
    local raw resolved
    raw="$(readlink "$1")"
    case "$raw" in "$REPO_ROOT"/*) return 0 ;; esac
    resolved="$(link_target "$1")"
    case "$resolved" in "$REPO_ROOT"/*) return 0 ;; esac
    return 1
}

# Newest "<target>.backup*" entry (bash sorts globs: ".backup" < ".backup.<ts>"
# < ".backup.<ts>.<n>", and ISO timestamps sort chronologically). Empty if none.
latest_backup() {
    local target="$1" b found=""
    for b in "$target".backup "$target".backup.*; do
        [ -e "$b" ] || continue
        found="$b"
    done
    printf '%s\n' "$found"
}

# --- enumeration: emit "SRC<TAB>TARGET_PARENT" for every managed entry ---
enumerate() {
    local root rootabs name e shsel
    for root in "$@"; do
        [ -d "$root" ] || continue
        rootabs="$(cd "$root" && pwd)"
        # 1) config children -> ~/.config/<name>  (dirs only; skip home/./*_ )
        for name in "$rootabs"/*/; do
            [ -d "$name" ] || continue
            name="$(basename "$name")"
            case "$name" in home | .* | _*) continue ;; esac
            printf '%s\t%s\n' "$rootabs/$name" "$CONFIG_HOME"
        done
        # 2) home children -> $HOME/<name>  (files AND dotfiles; skip _*/shells)
        if [ -d "$rootabs/home" ]; then
            shopt -s nullglob dotglob
            for e in "$rootabs/home"/*; do
                name="$(basename "$e")"
                case "$name" in _* | shells) continue ;; esac
                printf '%s\t%s\n' "$e" "$HOME"
            done
            # 3) selected shell's contents -> $HOME/<name>
            if [ -n "$SH" ] && [ -d "$rootabs/home/shells/$SH" ]; then
                for e in "$rootabs/home/shells/$SH"/*; do
                    name="$(basename "$e")"
                    case "$name" in _*) continue ;; esac
                    printf '%s\t%s\n' "$e" "$HOME"
                done
            fi
            shopt -u nullglob dotglob
        fi
    done
}

# --- backup + link a single source into TARGET_PARENT/<basename> ---
link_one() {
    local src="$1" parent="$2" name target backup ts n
    name="$(basename "$src")"
    target="$parent/$name"

    if [ -L "$target" ]; then
        if [ "$(link_target "$target")" = "$src" ]; then
            echo "  ok      $(tilde "$target") already linked"
            return
        fi
        echo "  replaced symlink $target"
        rm "$target"
    elif [ -e "$target" ]; then
        backup="$target.backup"
        if [ -e "$backup" ]; then
            ts="$(date +%Y%m%dT%H%M%S)"; backup="$backup.$ts"; n=1
            while [ -e "$backup" ]; do backup="$target.backup.$ts.$n"; n=$((n + 1)); done
        fi
        mv "$target" "$backup"
        echo "  backed up $(basename "$backup")"
    fi
    mkdir -p "$parent"
    ln -s "$src" "$target"
    echo "  linked   $target -> $src"
}

do_link() {
    local src parent
    while IFS=$'\t' read -r src parent; do
        link_one "$src" "$parent"
    done < <(enumerate "$@")
}

# Rollback one removed link: restore its newest backup, if any & not occupied.
rollback_one() {
    local link="$1" backup
    backup="$(latest_backup "$link")"
    if [ -n "$backup" ]; then
        if [ -e "$link" ]; then
            echo "  warn      $link reappeared, rollback skipped"
        else
            mv "$backup" "$link"
            echo "  restored  $(basename "$backup") -> $link"
        fi
    else
        echo "  note      no backup for $(basename "$link")"
    fi
}

# Sweep ~/.config and $HOME (incl. dotfiles) for repo symlinks and remove them.
do_unlink() {
    local dir link
    for dir in "$CONFIG_HOME" "$HOME"; do
        [ -d "$dir" ] || continue
        shopt -s nullglob dotglob
        for link in "$dir"/*; do
            [ -L "$link" ] || continue
            is_repo_link "$link" || continue
            rm "$link"
            echo "  removed   $link"
            [ "$ROLLBACK" = 1 ] && rollback_one "$link"
        done
        shopt -u nullglob dotglob
    done
}

# Label a path with ~ instead of $HOME for readable status output.
tilde() { printf '%s\n' "~${1#"$HOME"}"; }

do_status() {
    local src parent target state backup
    while IFS=$'\t' read -r src parent; do
        target="$parent/$(basename "$src")"
        backup="$(latest_backup "$target")"
        if is_repo_link "$target"; then
            state="linked    $(tilde "$target")"
        elif [ -L "$target" ]; then
            state="foreign   $(tilde "$target") (symlink points elsewhere)"
        elif [ -e "$target" ]; then
            state="local     $(tilde "$target") (would be backed up)"
        else
            state="absent    $(tilde "$target")"
        fi
        [ -n "$backup" ] && echo "  $state — rollback: $(basename "$backup")" || echo "  $state"
    done < <(enumerate "$@")

    # Repo-pointing symlinks whose source dir is gone (orphans)
    local dir link
    for dir in "$CONFIG_HOME" "$HOME"; do
        [ -d "$dir" ] || continue
        shopt -s nullglob dotglob
        for link in "$dir"/*; do
            [ -L "$link" ] || continue
            is_repo_link "$link" || continue
            [ -e "$link" ] && continue
            echo "  orphan    $(tilde "$link") ('make uninstall' cleans)"
        done
        shopt -u nullglob dotglob
    done
}

do_shells() {
    local root name
    for root in "$@"; do
        [ -d "$root" ] || continue
        [ -d "$root/home/shells" ] || continue
        for name in "$root/home/shells"/*/; do
            [ -d "$name" ] || continue
            name="$(basename "$name")"
            case "$name" in _* | .*) continue ;; esac
            if [ "$name" = "$SH" ]; then
                echo "  $name   (selected)"
            else
                echo "  $name"
            fi
        done
    done
}

echo "dotfiles: $REPO_ROOT   shell: ${SH:-<none>}"
case "$MODE" in
    link) do_link "${ROOTS[@]}" ;;
    unlink) do_unlink ;;
    status) do_status "${ROOTS[@]}" ;;
    shells) do_shells "${ROOTS[@]}" ;;
esac
