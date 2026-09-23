return {
	"atusy/treemonkey.nvim",
	keys = {
		{
			"m",
			function()
				require("treemonkey").select({ ignore_injections = false })
			end,
			mode = { "x", "o" },
			desc = "Select block",
		},
	},
	lazy = true,
	config = function()
		require("denops-lazy").load("treemonkey.nvim")
	end,
}
