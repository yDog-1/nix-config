return {
	"https://github.com/lewis6991/hover.nvim",
	keys = {
		{
			"K",
			function()
				require("hover").open()
			end,
			desc = "Hover",
		},
		{
			"gK",
			function()
				require("hover").enter()
			end,
			desc = "Hover (enter)",
		},
	},
	config = function()
		---@diagnostic disable-next-line: missing-fields, param-type-mismatch
		require("hover").config({
			providers = {
				{
					module = "hover.providers.lsp",
					priority = 200,
				},
				{
					module = "hover.providers.gh",
					priority = 150,
				},
				{
					module = "hover.providers.diagnostic",
					priority = 100,
				},
				{
					module = "hover.providers.highlight",
					priority = 80,
				},
				{
					module = "hover.providers.man",
					priority = 75,
				},
				{
					module = "hover.providers.dictionary",
					priority = 50,
				},
			},
		})
	end,
}
