#!/usr/bin/env bash
# link.sh — dynamically symlink every config directory in this repo into ~/.config
#
# Usage: scripts/link.sh <mode> <profile-dir> [...] [--rollback]
#   mode         link | unlink | status
#   profile-dir  directories whose *direct* children are configs to manage
#   --rollback   (unlink only) restore the latest ~/.config/<name>.backup*
#                after removing the repo symlink
#
# Each child directory becomes ~/.config/<basename>. Children whose name
# starts with '.' or '_' are skipped, so an '_experimental/' folder (or any
# hidden one) stays linked-out without touching this script. Nothing is ever
# hardcoded: to add a tool, just create <profile>/<name>/ and run `make`.
set -euo pipefail

usage() {
    echo "usage: $(basename "$0") <link|unlink|status> <profile-dir> [...] [--rollback]" >&2
    exit 2
}

MODE="${1:-}"
case "$MODE" in link | unlink | status) ;; *) usage ;; esac
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

# Print every child config directory (absolute path) found under the given
# profile roots, honoring the '.'/'_' skip convention.
discover() {
    local root name
    for root in "$@"; do
        [ -d "$root" ] || continue
        for name in "$root"/*/; do
            [ -d "$name" ] || continue
            name="$(basename "$name")"
            case "$name" in .* | _*) continue ;; esac
            printf '%s/%s\n' "$(cd "$root" && pwd)" "$name"
        done
    done
}

# Where ~/.config/<name> currently points, resolved to an absolute path.
# Returns empty for real dirs/files and broken or relative symlinks we
# cannot resolve portably (no readlink -f / realpath on older macOS).
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

# True if the target is a symlink into this repo — checked on the RAW link
# string first so dangling links (repo dir deleted) are caught even though
# they can no longer be resolved.
is_repo_link() {
    [ -L "$1" ] || return 1
    local raw resolved
    raw="$(readlink "$1")"
    case "$raw" in
        "$REPO_ROOT"/*) return 0 ;;
    esac
    resolved="$(link_target "$1")"
    case "$resolved" in
        "$REPO_ROOT"/*) return 0 ;;
    esac
    return 1
}

# Echo the newest "$target.backup*" entry, or nothing. Bash sorts glob
# expansion, and ".backup" < ".backup.<ts1>" < ".backup.<ts2>", so the last
# match is the latest (ISO-style timestamps sort chronologically).
latest_backup() {
    local target="$1" b found=""
    for b in "$target".backup "$target".backup.*; do
        [ -e "$b" ] || continue
        found="$b"
    done
    printf '%s\n' "$found"
}

do_link() {
    local src name target backup ts n
    while IFS= read -r src; do
        name="$(basename "$src")"
        target="$CONFIG_HOME/$name"

        if [ -L "$target" ]; then
            if [ "$(link_target "$target")" = "$src" ]; then
                echo "  ok       ~/.config/$name already linked"
                continue
            fi
            echo "  replaced symlink $target"
            rm "$target"
        elif [ -e "$target" ]; then
            backup="$target.backup"
            if [ -e "$backup" ]; then
                ts="$(date +%Y%m%dT%H%M%S)"
                backup="$backup.$ts"
                n=1
                while [ -e "$backup" ]; do backup="$target.backup.$ts.$n"; n=$((n + 1)); done
            fi
            mv "$target" "$backup"
            echo "  backed up $(basename "$backup")"
        fi

        mkdir -p "$CONFIG_HOME"
        ln -s "$src" "$target"
        echo "  linked    $target -> $src"
    done < <(discover "$@")
}

do_unlink() {
    local link name backup
    if [ ! -d "$CONFIG_HOME" ]; then
        echo "  nothing to do ($CONFIG_HOME does not exist)"
        return
    fi
    # Sweep ~/.config itself, so orphaned links (repo dir since deleted) are
    # removed too, not just ones whose source still exists.
    for link in "$CONFIG_HOME"/*; do
        [ -L "$link" ] || continue
        is_repo_link "$link" || continue
        name="$(basename "$link")"
        rm "$link"
        echo "  removed   $link"
        if [ "$ROLLBACK" = 1 ]; then
            backup="$(latest_backup "$link")"
            if [ -n "$backup" ]; then
                if [ -e "$link" ]; then
                    echo "  warn      $link reappeared, rollback skipped"
                else
                    mv "$backup" "$link"
                    echo "  restored  $(basename "$backup") -> $link"
                fi
            else
                echo "  note      no backup for $name"
            fi
        fi
    done
}

do_status() {
    local src name target backup state
    while IFS= read -r src; do
        name="$(basename "$src")"
        target="$CONFIG_HOME/$name"
        backup="$(latest_backup "$target")"
        state=""
        if is_repo_link "$target"; then
            state="linked    $name"
        elif [ -L "$target" ]; then
            state="foreign   $name (symlink points elsewhere)"
        elif [ -e "$target" ]; then
            state="local     $name (real dir in ~/.config, would be backed up)"
        else
            state="absent    $name"
        fi
        if [ -n "$backup" ]; then
            echo "  $state — rollback: $(basename "$backup")"
        else
            echo "  $state"
        fi
    done < <(discover "$@")

    # Links in ~/.config pointing into the repo whose source dir is gone
    [ -d "$CONFIG_HOME" ] || return
    for target in "$CONFIG_HOME"/*; do
        [ -L "$target" ] || continue
        is_repo_link "$target" || continue
        name="$(basename "$target")"
        if [ ! -e "$target" ]; then
            echo "  orphan    $name (repo dir deleted; 'make uninstall' cleans)"
        fi
    done
}

echo "dotfiles: $REPO_ROOT"
case "$MODE" in
    link) do_link "${ROOTS[@]}" ;;
    unlink) do_unlink "${ROOTS[@]}" ;;
    status) do_status "${ROOTS[@]}" ;;
esac
