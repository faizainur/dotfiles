return {
  { -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    branch = "main",
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "diff",
        "html",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "query",
        "vim",
        "vimdoc",
        "go",
        "clojure",
        "ruby",
        "javascript",
        "typescript",
        "make",
        "cmake",
        "java",
        "json",
        "toml",
        "yaml",
        "sql",
        "graphql",
        "terraform",
        "python",
        "gitignore",
        "tsx",
        "css",
        "templ",
        "svelte",
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { "ruby" },
      },
      indent = { enable = true, disable = { "ruby" } },
    },
    config = function(_, opts)
      -- Register filetypes BEFORE setting up treesitter
      vim.filetype.add({
        extension = {
          tf = "terraform",
          tfvars = "terraform",
          svelte = "svelte",
        },
      })

      require("nvim-treesitter").setup(opts)
    end,
  },
}
