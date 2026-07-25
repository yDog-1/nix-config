-- 日本語対応モーション
return {
	"atusy/jab.nvim",
	dependencies = {
		"lambdalisue/vim-kensaku",
	},
	lazy = true,
	keys = {

		{
			"f",
			function()
				return require("jab").f()
			end,
			mode = { "n", "x", "o" },
			expr = true,
		},
		{
			"F",
			function()
				return require("jab").F()
			end,
			mode = { "n", "x", "o" },
			expr = true,
		},
		{
			"t",
			function()
				return require("jab").t()
			end,
			mode = { "n", "x", "o" },
			expr = true,
		},
		{
			"T",
			function()
				return require("jab").T()
			end,
			mode = { "n", "x", "o" },
			expr = true,
		},
	},
}
