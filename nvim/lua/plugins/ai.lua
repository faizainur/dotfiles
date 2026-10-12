-- AI: avante + copilot.lua (ported from the repo config, was commented out there)
return {
  -- {
  -- 	"yetone/avante.nvim",
  -- 	event = "VeryLazy",
  -- 	commit = "ecc669a",
  -- 	dependencies = {
  -- 		"nvim-treesitter/nvim-treesitter",
  -- 		"nvim-lua/plenary.nvim",
  -- 		"MunifTanjim/nui.nvim",
  -- 		"folke/snacks.nvim",
  -- 		"nvim-tree/nvim-web-devicons",
  -- 		{
  -- 			"zbirenbaum/copilot.lua",
  -- 			opts = {
  -- 				disable_tools = false,
  -- 			},
  -- 		},
  -- 		{
  -- 			"HakonHarnes/img-clip.nvim",
  -- 			event = "VeryLazy",
  -- 			opts = {
  -- 				default = {
  -- 					embed_image_as_base64 = false,
  -- 					prompt_for_file_name = false,
  -- 					drag_and_drop = {
  -- 						insert_mode = true,
  -- 					},
  -- 				},
  -- 			},
  -- 		},
  -- 		"Kaiser-Yang/blink-cmp-avante",
  -- 	},
  -- 	opts = {
  -- 		provider = "copilot",
  -- 		providers = {
  -- 			copilot = {
  -- 				model = "gpt-4.1",
  -- 				disable_tools = false,
  -- 			},
  -- 		},
  -- 		build = "make BUILD_FROM_SOURCE=true",
  -- 		behaviour = {
  -- 			auto_suggestions = false,
  -- 		},
  -- 		suggestions = {
  -- 			debounce = 600,
  -- 			throttle = 600,
  -- 		},
  -- 	},
  -- },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      file_types = {
        "markdown",
        -- "Avante"
      },
    },
    ft = {
      "markdown",
      -- "Avante",
    },
  },
}
