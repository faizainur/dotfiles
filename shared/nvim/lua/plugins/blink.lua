-- blink.cmp: merge over LazyVim's defaults, port repo-specific tweaks
return {
  "saghen/blink.cmp",
  version = "1.*",
  dependencies = {
    {
      "L3MON4D3/LuaSnip",
      version = "2.*",
      build = (function()
        if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
          return
        end
        return "make install_jsregexp"
      end)(),
      dependencies = {
        {
          "rafamadriz/friendly-snippets",
          config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
          end,
        },
      },
      opts = {},
    },
  },
  opts = {
    completion = {
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 10,
      },
      ghost_text = {
        enabled = true,
      },
    },
    sources = {
      default = {
        -- "avante",
        "lsp",
        "path",
        "snippets",
        "lazydev",
      },
      providers = {
        -- avante = {
        -- 	module = "blink-cmp-avante",
        -- 	name = "Avante",
        -- },
      },
    },
    snippets = { preset = "luasnip" },
    fuzzy = { implementation = "prefer_rust" },
    signature = { enabled = true },
  },
}
