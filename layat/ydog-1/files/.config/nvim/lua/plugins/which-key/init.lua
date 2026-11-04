local spec = require("plugins.which-key.spec")

return {
	-- 操作方法を表示
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = function()
			return {
				preset = "helix",
				spec = spec.body,
			}
		end,
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts)
			wk.add({
				{ "<leader>w", proxy = "<c-w>", group = "windows" },
			})
		end,
	},
}
