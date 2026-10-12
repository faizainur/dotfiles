-- Editing plugins ported from the repo (collapse, misc, autopairs, comment,
-- indent-blankline, fidget/notify). mini.pairs is disabled in favor of nvim-autopairs.
return {
  { "nvim-mini/mini.pairs", enabled = false },

  -- Folding: nvim-ufo (+ promise-async dependency), folds stay open by default
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "VeryLazy",
    init = function()
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
    end,
    config = function()
      require("ufo").setup({
        close_fold_kinds_for_ft = {},
        open_fold_hl_timeout = 150,
      })

      vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
      vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds, { desc = "Open folds except kinds" })
      vim.keymap.set("n", "zm", require("ufo").closeFoldsWith, { desc = "Close folds with" })
    end,
  },

  -- Surround
  {
    "kylechui/nvim-surround",
    version = "^3.1.8",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- Comments (Comment.nvim) + the repo's <leader>/ keymaps
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()

      vim.keymap.set("n", "<leader>/", function()
        require("Comment.api").toggle.linewise.current()
      end, { desc = "Toggle comment" })

      vim.keymap.set("v", "/", function()
        local api = require("Comment.api")
        local start_line = vim.fn.line("v")
        local end_line = vim.fn.line(".")
        local count_line_number = math.abs(end_line - start_line) + 1
        if count_line_number > 1 then
          api.toggle.linewise(vim.fn.visualmode())
        else
          api.toggle.linewise.current()
        end
      end, { desc = "Toggle comment in Visual mode" })
    end,
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
  },

  -- LSP progress + notification UI
  { "j-hui/fidget.nvim",    opts = {} },
  { "rcarriga/nvim-notify", opts = {} },
}
