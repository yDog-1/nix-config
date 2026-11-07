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
}
