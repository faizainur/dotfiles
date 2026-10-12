-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Window management (ported from the old repo config)
vim.keymap.set("n", "<leader>v", "<C-w>v", { desc = "Split vertically", remap = false })   -- split window vertically
vim.keymap.set("n", "<leader>s", "<C-w>s", { desc = "Split horizontally", remap = false }) -- split window horizontally (down)
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Equal split size", remap = false })  -- make split windows equal width
vim.keymap.set("n", "<leader>xs", ":close<CR>", { desc = "Close split", silent = true })   -- close current split window

-- Keymaps for neotest
local neotest = require("neotest")
vim.keymap.set("n", "<leader>tn", function()
    neotest.run.run()
end, { desc = "Run nearest test" })
vim.keymap.set("n", "<leader>tf", function()
    neotest.run.run(vim.fn.expand("%"))
end, { desc = "Run tests in current file" })
vim.keymap.set("n", "<leader>tN", function()
    neotest.run.stop()
end, { desc = "Stop running tests" })
vim.keymap.set("n", "<leader>to", function()
    neotest.output.open({ enter = true })
end, { desc = "Open test output" })
vim.keymap.set("n", "<leader>tp", function()
    neotest.output_panel.toggle()
end, { desc = "Toggle test output panel" })
vim.keymap.set("n", "<leader>ts", function()
    neotest.summary.toggle()
end, { desc = "Toggle test summary" })
vim.keymap.set("n", "<leader>tS", function()
    neotest.summary.open()
end, { desc = "Open test summary" })
vim.keymap.set("n", "<leader>tT", function()
    neotest.run.attach()
end, { desc = "Attach to test" })
vim.keymap.set("n", "<leader>tR", function()
    neotest.run.run({ suite = true })
end, { desc = "Run all tests in suite" })
vim.keymap.set("n", "<leader>tb", function()
    neotest.run.run({ strategy = "dap" })
end, { desc = "Debug test" })
