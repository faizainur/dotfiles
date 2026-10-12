-- Set the default encoding to UTF-8
vim.g.have_nerd_font = true
vim.g.have_nerd_font = true
vim.g.have_nerd_font = true

-- Set line numbers
vim.o.number = true
vim.o.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = "a"

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.o.clipboard = "unnamedplus"
end)

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Show line cursor
vim.o.cursorline = true

-- Raise configmration when quting unsaved buffer
vim.o.confirm = true

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

vim.o.wrap = false
vim.o.linebreak = true

vim.o.autoindent = true

-- Use spaces
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.shiftwidth = 4 -- Number of spaces for each indent
vim.opt.tabstop = 4 -- Number of spaces a <Tab> displays as
vim.opt.softtabstop = 4 -- Number of spaces a <Tab> inserts in insert mode
