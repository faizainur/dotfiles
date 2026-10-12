# nvim — customized LazyVim setup

Neovim configuration **based on [LazyVim](https://github.com/LazyVim/LazyVim)**
(the `lazyvim.plugins` distribution), extended and overridden with plugins
ported from a personal config. In this dotfiles repo it lives under
`shared/nvim/` and is symlinked to `~/.config/nvim` by `make install`.

## How it's structured

LazyVim provides the core spec (picker/lsp/treesitter/ui defaults); this
config only *adds/overrides* through `:h lazy.nvim` import:

```
init.lua                # entry: loads config/ then imports plugins/
lua/
├── config/
├── config/
│   ├── lazy.lua          # lazy.nvim bootstrap + LazyVim import
│   ├── options.lua       # editor options (mostly LazyVim defaults)
│   ├── keymaps.lua       # custom keymaps (window mgmt + neotest, below)
│   └── autocmds.lua      # stock template (no custom autocmds yet)
└── plugins/              # one file per topic — the actual customizations
```

## Plugin stack (per `plugins/*.lua`)

| File | What it sets up |
|---|---|
| `formatter.lua` | **none-ls deprecated** — formatting falls back to LazyVim's default **conform.nvim** (format-on-save). File kept as `return {}` placeholder. |
| `mason.lua` | `mason-tool-installer` with canonical mason package IDs (gopls, pyright, rust-analyzer, lua-language-server, typescript-language-server, html-lsp, svelte-language-server, templ, cljfmt, stylua…). Declares `mason.nvim` as dependency so the registry loads before installs. |
| `blink.lua` | `blink.cmp` (1.*) completion, merged over LazyVim defaults, with LuaSnip 2.* snippets. |
| `dap.lua` | `nvim-dap` + `dap-ui` + `dap-go` + `dap-ruby`. **External requirement:** the pwa-node adapter expects `~/.config/vscode-js-debug/js-debug/src/dapDebugServer.js`. |
| `testing.lua` | `neotest` stack (rspec, golang, jest, vim-test adapters) + `vim-test`. Keymaps below. |
| `snacks.lua` | Explorer: does **not** hijack netrw (`<leader>e` on demand); file tree always shows dotfiles (`hidden = true`). Picker navigation table below. |
| `macros.lua` | Custom **Macros picker** (`<leader>m`): lists non-empty named registers (a–z, 0–9) with preview; `<CR>` plays back the selected macro. For all registers use `<leader>s"` (built-in Snacks registers picker). |
| `editing.lua` | `nvim-ufo` folding (folds open by default), `nvim-surround`, `nvim-autopairs` (mini.pairs disabled), `Comment.nvim`, `indent-blankline`. |
| `git.lua` | `git-blame.nvim` (inline virtual-text blame) + `lazygit.nvim`. |
| `lang.lua` | `vim-go`, **`typescript-tools.nvim`** (replaces plain tsserver LSP), `live-server.nvim`, `nvim-rg`. |
| `icons.lua` | `nvim-web-devicons` (needed by ai tooling; core UI uses mini.icons). |
| `ai.lua` | Currently **disabled** avante/copilot.lua specs (commented out); only `render-markdown.nvim` active. |

## Custom keymaps

Window management (`config/keymaps.lua`):

| Key | Action |
|---|---|
| `<leader>v` / `<leader>s` | split vertical / horizontal |
| `<leader>se` | equalize split sizes |
| `<leader>xs` | close split |

Tests (neotest, `config/keymaps.lua`):

| Key | Action |
|---|---|
| `<leader>tn` | run nearest test |
| `<leader>tf` | run tests in current file |
| `<leader>tR` | run whole suite |
| `<leader>tb` | debug test (dap) |
| `<leader>tN` / `<leader>tT` | stop / attach |
| `<leader>to` / `<leader>tp` | output window / output panel |
| `<leader>ts` / `<leader>tS` | summary toggle / open |

Git:

| Key | Action |
|---|---|
| `<leader>lg` | LazyGit |

Debugging (DAP, `plugins/dap.lua`):

| Key | Action |
|---|---|
| `<F5>` | start / continue |
| `<F10>` / `<F11>` / `<F12>` | step over / into / out |
| `<leader>bt` | toggle breakpoint |
| `<leader>B` | set breakpoint (prompts for optional condition) |
| `<leader>dr` | open REPL |
| `<leader>dl` | re-run last session |
| `<leader>de` | evaluate expression / visual selection (dap-ui) |
| `<leader>dh` | hover widget (normal + visual) |
| `<leader>dp` | preview widget (normal + visual) |
| `<leader>df` / `<leader>ds` | frames / scopes centered float |
| `<leader>dgt` | Go: debug test (`dap-go`) |

dap-ui **opens automatically** on launch/attach and closes on
terminate/exit (listeners in `dap.lua`); no separate open/toggle keys are
defined. Breakpoint gutter signs: 🛑 breakpoint, 🟡 conditional, ❌ rejected,
📘 log point. JS/TS debugging needs the external `vscode-js-debug` adapter
(see Requirements). Debugging tests from neotest uses `<leader>tb` (tests
table above).

## Snacks picker navigation

Pickers open as multiple panes: an **input** box, a **list** of results
(left), and a **preview** of the selected item (right).

| Action | Key |
|---|---|
| Move focus between panes (input / list / preview) | `<a-w>` (cycle_win) |
| Toggle focus input ↔ list | `/` |
| Jump to input box from any pane | `i` |
| Scroll the preview without entering it | `<c-f>` / `<c-b>` |
| Show / hide the preview pane | `<a-p>` |
| Re-layout panes (preview below, left, etc.) | `<c-w>H` / `J` / `K` / `L` |
| Open selection in the last-used window | `<S-CR>` |
| Cancel picker | `q` / `<Esc>` |

Inside the preview pane it behaves like a normal window (motions,
`gg`/`G`, etc.); leave with `<a-w>` again, or close the picker with
`q`/`<Esc>`.

> Note: `<a-…>` bindings require the terminal to send Alt sequences.
> Works out of the box in kitty/wezterm/alacritty and most Linux terminals.

Scratch buffers (`Snacks.scratch`, provided by snacks + LazyVim):

| Key | Action |
|---|---|
| `<leader>.` | create / toggle a scratch buffer |
| `<leader>S` | select between existing scratch buffers (empty until one exists) |
| `<leader>uz` | toggle zen mode |
| `<leader>wm` / `<leader>uZ` | toggle zoom (width-only focus) |

Macros (`plugins/macros.lua`):

| Key | Action |
|---|---|
| `<leader>m` | open the **Macros** picker — one line per non-empty named register (a–z, 0–9), preview shows the recorded keystrokes |
| `<CR>` | play back the selected macro (equivalent to `@{reg}`) |
| `{count}<leader>m` | play the macro **count times** (`3<leader>m` ≡ `3@q`); type the count before opening — digits inside the picker belong to the filter |


## Requirements

- Neovim ≥ 0.9.x (LazyVim requirement), `git`, `make`, a Nerd Font
- `fd` + `ripgrep` for the best picker experience
- `node` for typescript-tools / live-server; `pnpm` recommended
- For JS/TS debugging: `~/.config/vscode-js-debug` (dap.lua note above)
- Optional: `lazygit` binary, language toolchains (go, ruby, python)

## Install

Nothing here is installed manually — `make install` from the dotfiles repo
root symlinks `shared/nvim/` → `~/.config/nvim` (backing up any pre-existing
config). On first launch lazy.nvim bootstraps itself and installs the plugin
graph; mason-tool-installer downloads the tools listed in `mason.lua`.
