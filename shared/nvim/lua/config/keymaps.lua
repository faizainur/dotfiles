-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Window management (ported from the old repo config)
vim.keymap.set("n", "<leader>v", "<C-w>v", { desc = "Split vertically", remap = false })   -- split window vertically
vim.keymap.set("n", "<leader>s", "<C-w>s", { desc = "Split horizontally", remap = false }) -- split window horizontally (down)
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Equal split size", remap = false })  -- make split windows equal width
vim.keymap.set("n", "<leader>xs", ":close<CR>", { desc = "Close split", silent = true })   -- close current split window

-- Toggle terminal in a bottom split (open/close with the same key)
local function toggle_terminal()
  -- if a terminal window is open anywhere, close it
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" then
      vim.api.nvim_win_close(win, true)
      return
    end
  end
  -- otherwise open a new terminal in a bottom pane
  vim.cmd("belowright 15split")
  vim.cmd("terminal")
  vim.cmd("startinsert")
end

-- vim.keymap.set("n", "<C-/>", toggle_terminal, { desc = "Toggle terminal (bottom)" })
-- vim.keymap.set("t", "<C-/>", [[<C-\><C-n><C-w>c]], { desc = "Close terminal" })
