-- Mason tooling ported from the repo (mason-tool-installer + mason-null-ls)
-- NOTE: mason-null-ls is part of the none-ls formatter setup (formatter.lua).
-- Entries must be mason package IDs (hyphenated) or lspconfig names that
-- mason-lspconfig can translate; declaring mason.nvim as a dependency
-- guarantees the registry is loaded before the installer runs, regardless
-- of whether none-ls is in the spec.
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      -- canonical mason package IDs (see ~/.local/share/nvim/mason/registries)
      ensure_installed = {
        "gopls",
        "pyright",
        "rust-analyzer",
        "lua-language-server",
        -- "ruby-lsp",
        -- "solargraph",
        -- "rubocop",
        "clojure-lsp",
        "cljfmt",
        "gitlab-ci-ls",
        -- "rubyfmt",
        "typescript-language-server",
        "html-lsp",
        "templ",
        "svelte-language-server",
        "stylua",
      },
    },
    config = function(_, opts)
      require("mason-tool-installer").setup(opts)
    end,
  },
}
