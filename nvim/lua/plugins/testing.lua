-- Testing: neotest stack + coverage ported from the repo (neotest.lua, coverage.lua)
return {
	{
		"vim-test/vim-test",
	},
	{
		"nvim-neotest/neotest",
		lazy = true,
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			"olimorris/neotest-rspec",
			{ "fredrikaverpil/neotest-golang", version = "*" },
			"nvim-neotest/neotest-jest",
			"nvim-neotest/neotest-vim-test",
		},
		config = function()
			local neotest = require("neotest")
			neotest.setup({
				adapters = {
					require("neotest-rspec")({
						rspec_cmd = function(position_type)
							if position_type == "test" then
								return vim.tbl_flatten({
									"bundle",
									"exec",
									"rspec",
									"--fail-fast",
								})
							else
								return vim.tbl_flatten({
									"bundle",
									"exec",
									"rspec",
								})
							end
						end,
						root_files = {
							".gitignore",
							"Gemfile",
							"Jarfile",
							"README.md",
							"README",
							"Makefile",
						},
					}),
					require("neotest-golang")({
						go_test_args = { "-v", "-count=1", "-race", "-cover" },
						testify_enabled = true,
						dap_go_enabled = false,
					}),
					require("neotest-jest")({
						jestCommand = "npm test --",
						jestConfigFile = "custom.jest.config.ts",
						env = { CI = true },
						cwd = function(path)
							return vim.fn.getcwd()
						end,
					}),
					require("neotest-vim-test")({
						allow_file_types = {
							"clojure",
							"rspec",
						},
					}),
				},
			})

			-- neotest keymaps (ported from the repo's config/keymaps.lua)
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
		end,
	},
	{
		"andythigpen/nvim-coverage",
		version = "*",
		config = function()
			require("coverage").setup({
				auto_reload = true,
				highlights = {
					covered = { fg = "#C3E88D" },
					uncovered = { fg = "#F07178" },
				},
				signs = {
					covered = { hl = "CoverageCovered", text = "▎" },
					uncovered = { hl = "CoverageUncovered", text = "▎" },
				},
				summary = {
					min_coverage = 90.0,
				},
				lang = {},
			})
		end,
	},
}
