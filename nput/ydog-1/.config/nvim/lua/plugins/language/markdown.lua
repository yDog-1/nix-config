return {
	{
		"delphinus/md-render.nvim",
		dependencies = {
			{ "nvim-tree/nvim-web-devicons" },
			{ "delphinus/budoux.lua" },
		},
		keys = {
			{ "<leader>lm", "<Plug>(md-render-preview)", desc = "Markdown preview (toggle)" },
			{ "<leader>lt", "<Plug>(md-render-preview-tab)", desc = "Markdown preview in tab (toggle)" },
		},
	},
	{
		"jmbuhr/otter.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {},
		config = function(_, opts)
			local otter = require("otter")
			otter.setup(opts)

			-- vim.api.nvim_create_autocmd("filetype", {
			-- 	pattern = "markdown",
			-- 	callback = function(o)
			-- 		local buf = o.buf
			-- 		-- Check if buffer is writable before activating Otter
			-- 		if not vim.bo[buf].readonly then
			-- 			otter.activate(nil, true, false)
			-- 		end
			-- 	end,
			-- })
		end,
	},
}
