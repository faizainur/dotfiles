return {
	"folke/snacks.nvim",
	opts = {
		explorer = {
			-- Don't hijack "nvim ." (directory args) into auto-opening the file tree.
			-- The explorer is still available on demand with <leader>e
			replace_netrw = false,
		},
		picker = {
			sources = {
				explorer = {
					hidden = true, -- always show dotfiles in the file tree
				},
			},
		},
	},
}
