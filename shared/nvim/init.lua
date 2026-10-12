require("config.lazy")

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "go", "typescript", "javascript", "lua", "svelte", "ruby", "python", "html", "css" },
    callback = function()
        vim.treesitter.start()
    end,
})
