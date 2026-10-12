-- Mason tooling ported from the repo (mason-tool-installer + mason-null-ls)
-- NOTE: mason-null-ls is part of the none-ls formatter setup (formatter.lua).
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      -- mirrors the repo's lsp.lua ensure_installed list (servers + tools)
      ensure_installed = {
        "gopls",
        "pyright",
        "rust_analyzer",
        "lua_ls",
        -- "ruby_lsp",
        -- "solargraph",
        -- "rubocop",
        "clojure_lsp",
        "cljfmt",
        "gitlab_ci_ls",
        -- "rubyfmt",
        "typescript_language_server",
        "html_lsp",
        "templ",
        "svelte",
        "stylua",
      },
    },
    config = function(_, opts)
      require("mason-tool-installer").setup(opts)
    end,
  },
}
