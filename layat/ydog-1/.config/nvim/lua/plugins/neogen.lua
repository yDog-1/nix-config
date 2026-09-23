return {
	"danymat/neogen",
	dependencies = "nvim-treesitter/nvim-treesitter",
	keys = {
		{
			"<leader>cm",
			function()
				require("neogen").generate()
			end,
			desc = "Generate Documentation",
		},
	},
	config = true,
}
