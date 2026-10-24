return {
  { -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    -- LazyVim's default spec handles the `main` branch API: setup(),
    -- installing ensure_installed in the background, and a guarded
    -- vim.treesitter.start() FileType autocmd. Only extend opts here.
    opts = {
      ensure_installed = {
        "clojure",
        "cmake",
        "css",
        "gitignore",
        "go",
        "graphql",
        "java",
        "make",
        "ruby",
        "svelte",
        "sql",
        "templ",
        "terraform",
      },
      indent = { disable = { "ruby" } },
    },
  },
}
